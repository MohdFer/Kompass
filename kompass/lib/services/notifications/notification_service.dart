import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Cloud Messaging push notifications.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions.
  Future<void> initialize() async {
    // Request notification permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true, // For SOS alerts
    );

    debugPrint('FCM Permission: ${settings.authorizationStatus}');

    // Get FCM token for this device
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle messages received while app is in foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    // TODO: Show in-app notification banner
  }

  /// Handle notification tap that opens the app from background.
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tap: ${message.data}');
    // TODO: Navigate to relevant screen based on message data
  }

  /// Subscribe to a topic (e.g., tour-specific notifications).
  Future<void> subscribeToTour(String tourId) async {
    await _messaging.subscribeToTopic('tour_$tourId');
  }

  /// Unsubscribe from a tour topic.
  Future<void> unsubscribeFromTour(String tourId) async {
    await _messaging.unsubscribeFromTopic('tour_$tourId');
  }
}
