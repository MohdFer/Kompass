import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_toast.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/emergency/data/models/sos_alert_model.dart';
import '../../features/messaging/data/models/announcement_model.dart';
import '../../features/messaging/data/models/message_model.dart';
import '../../features/tour/data/models/tour_model.dart';
import '../../features/tour/providers/tour_providers.dart';
import 'notification_service.dart';

/// Service responsible for real-time chat, broadcast announcements, and SOS notification alerts
/// across all tours the user is part of.
class ChatNotificationService {
  ChatNotificationService._();
  static final instance = ChatNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _activeChatTourId;
  String? get activeChatTourId => _activeChatTourId;

  /// Sets the currently opened chat tour screen ID so that notifications
  /// are suppressed while actively inside that chat room.
  void setActiveChatTourId(String? tourId) {
    _activeChatTourId = tourId;
  }

  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _messageSubscriptions = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _sosSubscriptions = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _announcementSubscriptions = {};

  final Set<String> _seenMessageIds = {};
  final Set<String> _seenAlertIds = {};
  final Set<String> _seenAnnouncementIds = {};
  DateTime _sessionStartTime = DateTime.now();

  String? _currentUserId;

  /// Syncs notification listeners for all tours the user is part of.
  void syncTourListeners({
    required String? userId,
    required List<TourModel> allTours,
  }) {
    if (userId == null) {
      _cancelAllSubscriptions();
      _currentUserId = null;
      return;
    }

    if (_currentUserId != userId) {
      _cancelAllSubscriptions();
      _currentUserId = userId;
      _seenMessageIds.clear();
      _seenAlertIds.clear();
      _seenAnnouncementIds.clear();
      _sessionStartTime = DateTime.now();
    }

    final myTours = allTours.where((t) {
      return t.guideId == userId || t.participantIds.contains(userId);
    }).toList();

    final activeTourIds = myTours.map((t) => t.tourId).toSet();

    // Remove subscriptions for tours no longer joined
    _messageSubscriptions.keys
        .where((id) => !activeTourIds.contains(id))
        .toList()
        .forEach((id) {
      _messageSubscriptions[id]?.cancel();
      _messageSubscriptions.remove(id);
      NotificationService.instance.unsubscribeFromTour(id);
    });

    _sosSubscriptions.keys
        .where((id) => !activeTourIds.contains(id))
        .toList()
        .forEach((id) {
      _sosSubscriptions[id]?.cancel();
      _sosSubscriptions.remove(id);
    });

    _announcementSubscriptions.keys
        .where((id) => !activeTourIds.contains(id))
        .toList()
        .forEach((id) {
      _announcementSubscriptions[id]?.cancel();
      _announcementSubscriptions.remove(id);
    });

    // Start subscriptions for joined tours
    for (final tour in myTours) {
      NotificationService.instance.subscribeToTour(tour.tourId);

      if (!_messageSubscriptions.containsKey(tour.tourId)) {
        _listenToTourMessages(tour);
      }
      if (!_sosSubscriptions.containsKey(tour.tourId)) {
        _listenToTourSOS(tour);
      }
      if (!_announcementSubscriptions.containsKey(tour.tourId)) {
        _listenToTourAnnouncements(tour);
      }
    }
  }

  void _listenToTourMessages(TourModel tour) {
    final sub = _firestore
        .collection('Tours')
        .doc(tour.tourId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final doc = change.doc;
            final message = MessageModel.fromFirestore(doc);

            // Skip own messages
            if (message.senderId == _currentUserId) continue;

            // Skip messages already processed
            if (_seenMessageIds.contains(message.messageId)) continue;
            _seenMessageIds.add(message.messageId);

            // Skip historical messages created before current app session
            if (message.timestamp != null &&
                message.timestamp!.isBefore(
                  _sessionStartTime.subtract(const Duration(seconds: 10)),
                )) {
                continue;
            }

            // If the user is currently viewing this exact chat, skip notification alerts
            if (_activeChatTourId == tour.tourId) continue;

            // 1. Post real Android system notification alert
            final sender = message.senderName.isNotEmpty
                ? message.senderName
                : 'Expedition Crew';
            NotificationService.instance.showNotification(
              id: message.messageId.hashCode,
              title: '💬 $sender (${tour.name})',
              body: message.message,
              payload: 'chat:${tour.tourId}',
            );

            // 2. Play haptic feedback
            try {
              HapticFeedback.mediumImpact();
            } catch (_) {}

            // 3. Show in-app high contrast notification banner
            AppToast.showInfo(
              '💬 $sender: ${message.message}',
            );
          }
        }
      },
      onError: (e) {
        debugPrint('Error listening to messages in tour ${tour.tourId}: $e');
      },
    );

    _messageSubscriptions[tour.tourId] = sub;
  }

  void _listenToTourSOS(TourModel tour) {
    final sub = _firestore
        .collection('Tours')
        .doc(tour.tourId)
        .collection('SOSAlerts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final doc = change.doc;
            final alert = SosAlertModel.fromFirestore(doc);

            if (alert.userId == _currentUserId) continue;
            if (_seenAlertIds.contains(alert.alertId)) continue;
            _seenAlertIds.add(alert.alertId);

            final hasCoords = alert.latitude != 0.0 || alert.longitude != 0.0;
            final coordsText = hasCoords
                ? 'GPS: ${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}'
                : 'GPS: Pending fix';
            final reason = alert.message.isNotEmpty ? alert.message : 'Emergency distress signal';

            // Post emergency system notification with relevant details to guide & participants
            NotificationService.instance.showNotification(
              id: alert.alertId.hashCode,
              title: '🚨 EMERGENCY SOS: ${alert.userName}',
              body: '$reason in "${tour.name}"! $coordsText. Tap for emergency response.',
              payload: 'sos:${tour.tourId}',
            );

            try {
              HapticFeedback.heavyImpact();
            } catch (_) {}

            AppToast.showError(
              '🚨 CRITICAL SOS: ${alert.userName} sent distress beacon in "${tour.name}"!\n$coordsText • $reason',
              title: 'EMERGENCY DISTRESS BEACON',
              duration: const Duration(seconds: 8),
            );
          }
        }
      },
      onError: (e) {
        debugPrint('Error listening to SOS in tour ${tour.tourId}: $e');
      },
    );

    _sosSubscriptions[tour.tourId] = sub;
  }

  void _listenToTourAnnouncements(TourModel tour) {
    final sub = _firestore
        .collection('Tours')
        .doc(tour.tourId)
        .collection('Announcements')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final doc = change.doc;
            final announcement = AnnouncementModel.fromFirestore(doc);

            // Skip own announcements
            if (announcement.createdBy == _currentUserId) continue;

            // Skip announcements already processed
            if (_seenAnnouncementIds.contains(announcement.announcementId)) continue;
            _seenAnnouncementIds.add(announcement.announcementId);

            // Skip historical announcements from before current session
            if (announcement.timestamp != null &&
                announcement.timestamp!.isBefore(
                  _sessionStartTime.subtract(const Duration(seconds: 10)),
                )) {
              continue;
            }

            final sender = announcement.createdByName.isNotEmpty
                ? announcement.createdByName
                : 'Tour Guide';

            // 1. Post real Android system notification alert
            NotificationService.instance.showNotification(
              id: announcement.announcementId.hashCode,
              title: '📢 BROADCAST: ${announcement.title}',
              body: '${announcement.message}\n— $sender (${tour.name})',
              payload: 'announcement:${tour.tourId}',
            );

            // 2. Play haptic feedback
            try {
              HapticFeedback.heavyImpact();
            } catch (_) {}

            // 3. Show high-contrast alert banner
            AppToast.showWarning(
              '📢 BROADCAST (${tour.name}): ${announcement.title}\n${announcement.message}',
              title: 'IMPORTANT TOUR UPDATE',
              duration: const Duration(seconds: 6),
            );
          }
        }
      },
      onError: (e) {
        debugPrint('Error listening to announcements in tour ${tour.tourId}: $e');
      },
    );

    _announcementSubscriptions[tour.tourId] = sub;
  }

  void _cancelAllSubscriptions() {
    for (final sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscriptions.clear();

    for (final sub in _sosSubscriptions.values) {
      sub.cancel();
    }
    _sosSubscriptions.clear();

    for (final sub in _announcementSubscriptions.values) {
      sub.cancel();
    }
    _announcementSubscriptions.clear();
  }
}

/// Riverpod provider to automatically coordinate background & real-time chat notifications
final chatNotificationCoordinatorProvider = Provider<void>((ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final allTours = ref.watch(toursProvider).valueOrNull ?? [];

  ChatNotificationService.instance.syncTourListeners(
    userId: currentUser?.userId,
    allTours: allTours,
  );
});
