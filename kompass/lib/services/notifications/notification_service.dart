import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_notification_service.dart';
import 'web_notification_helper.dart';

/// Service for handling push notifications & local device notification alerts.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<RemoteMessage> _foregroundMessagesController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream of foreground notifications for UI banners.
  Stream<RemoteMessage> get foregroundMessages =>
      _foregroundMessagesController.stream;

  String? _lastOpenedTourId;
  String? get lastOpenedTourId => _lastOpenedTourId;

  void Function(String tourId)? onNotificationTapCallback;

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
    'kompass_chat_channel',
    'KOMPASS Expedition Radio',
    description: 'Notifications for tour chat messages and group alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize FCM and local notification alerts with full Android 13+ support.
  Future<void> initialize() async {
    // 1. Request Android 13+ system notification permission
    if (!kIsWeb) {
      try {
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      } catch (e) {
        debugPrint('System notification permission request skipped: $e');
      }
    }

    // 2. Initialize FlutterLocalNotifications for device-level alerts (native only)
    if (!kIsWeb) {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      try {
        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            final payload = response.payload;
            if (payload != null && payload.isNotEmpty) {
              _lastOpenedTourId = payload;
              onNotificationTapCallback?.call(payload);
            }
          },
        );

        // Create high-priority notification channel on Android
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_chatChannel);
      } catch (e) {
        debugPrint('Local notifications init error: $e');
      }
    }

    // 3. Request FCM Permissions
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
      debugPrint('FCM Permission status: ${settings.authorizationStatus}');

      // Enable heads-up alerts while in foreground
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!kIsWeb) {
        final token = await _messaging.getToken();
        debugPrint('FCM Token: $token');
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM Token Refreshed: $newToken');
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) {
            saveUserToken(userId);
          }
        });
      } else {
        // On web, if permission is already granted, fetch token & listen for refresh
        try {
          if (WebNotificationHelper.permission == WebNotificationPermission.granted) {
            final token = await _messaging.getToken();
            debugPrint('Web FCM Token: $token');
            _messaging.onTokenRefresh.listen((newToken) {
              debugPrint('Web FCM Token Refreshed: $newToken');
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                saveUserToken(userId);
              }
            });
          }
        } catch (e) {
          debugPrint('Web FCM token registration deferred: $e');
        }
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is launched from terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  /// Request web notification permission, register token, and return status
  Future<bool> requestWebNotificationPermission() async {
    if (!kIsWeb) return true;
    try {
      final perm = await WebNotificationHelper.requestPermission();
      if (perm == WebNotificationPermission.granted) {
        try {
          final token = await _messaging.getToken();
          if (token != null && token.isNotEmpty) {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null) {
              await saveUserToken(userId);
            }
          }
        } catch (e) {
          debugPrint('Web token retrieval deferred: $e');
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting web notification permission: $e');
      return false;
    }
  }

  /// Get current web notification permission status
  WebNotificationPermission getWebPermissionStatus() {
    if (!kIsWeb) return WebNotificationPermission.granted;
    return WebNotificationHelper.permission;
  }

  /// Save device FCM push token to the user document in Firestore so push notifications can reach this user.
  Future<void> saveUserToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance.collection('Users').doc(userId).set({
          'fcmToken': token,
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          if (kIsWeb) 'webNotificationsEnabled': true,
        }, SetOptions(merge: true));
        debugPrint('Saved FCM token to user document $userId');
      }
    } catch (e) {
      debugPrint('Error saving FCM token to user document: $e');
    }
  }

  /// Show an immediate high-priority notification alert on the device or web browser.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      final isEmergency = payload?.startsWith('sos:') ?? false;
      WebNotificationHelper.playNotificationChime(isEmergency: isEmergency);
      WebNotificationHelper.showWebNotification(
        title: title,
        body: body,
        tag: id.toString(),
        payload: payload,
        requireInteraction: isEmergency,
        onClick: (p) {
          if (p != null && p.isNotEmpty) {
            _lastOpenedTourId = p;
            onNotificationTapCallback?.call(p);
          }
        },
      );
      return;
    }

    // Ensure 32-bit signed integer compatibility required by Android NotificationManager
    final int safeId = id.abs() & 0x7FFFFFFF;

    const androidDetails = AndroidNotificationDetails(
      'kompass_chat_channel',
      'KOMPASS Expedition Radio',
      channelDescription:
          'Notifications for tour chat messages, announcements, and SOS alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'KOMPASS Alert',
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    try {
      await _localNotifications.show(
        safeId,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Handle messages received while app is in foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground FCM message: ${message.notification?.title}');

    // Skip notifying sender about their own dispatched message
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final senderId = message.data['senderId']?.toString();
    if (currentUserId != null && senderId != null && currentUserId == senderId) {
      debugPrint('Skipping self-sent FCM notification in foreground');
      return;
    }

    final String? tourId = message.data['tourId']?.toString();
    final String? type = message.data['type']?.toString();

    // If currently looking at this active tour chat screen, suppress notification
    if (type == 'chat' &&
        tourId != null &&
        ChatNotificationService.instance.activeChatTourId == tourId) {
      debugPrint('Suppressing chat notification because user is actively inside this chat room');
      return;
    }

    // Suppress if in-app live listener already displayed this notification
    final messageId = message.data['messageId']?.toString();
    if (messageId != null &&
        ChatNotificationService.instance.hasSeenMessage(messageId)) {
      debugPrint('Already shown by Firestore live listener: $messageId');
      return;
    }

    final String title = message.notification?.title ??
        message.data['title']?.toString() ??
        'KOMPASS Chat';
    final String body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (body.isNotEmpty) {
      showNotification(
        id: message.hashCode,
        title: title,
        body: body,
        payload: tourId,
      );
    }
    _foregroundMessagesController.add(message);
  }

  /// Handle notification tap that opens the app from background.
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tap: ${message.data}');
    final tourId = message.data['tourId'] as String?;
    if (tourId != null && tourId.isNotEmpty) {
      _lastOpenedTourId = tourId;
      onNotificationTapCallback?.call(tourId);
    }
  }

  /// Subscribe to a topic (e.g., tour-specific notifications).
  Future<void> subscribeToTour(String tourId) async {
    if (kIsWeb) return;
    try {
      await _messaging.subscribeToTopic('tour_$tourId');
    } catch (e) {
      debugPrint('FCM subscribeToTopic error: $e');
    }
  }

  /// Unsubscribe from a tour topic.
  Future<void> unsubscribeFromTour(String tourId) async {
    if (kIsWeb) return;
    try {
      await _messaging.unsubscribeFromTopic('tour_$tourId');
    } catch (e) {
      debugPrint('FCM unsubscribeFromTopic error: $e');
    }
  }
}
