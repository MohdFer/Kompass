import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notifications/notification_service.dart';
import 'services/storage/hive_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Handling background FCM push: ${message.messageId} title: ${message.notification?.title}');

  // If received as a data-only payload in background/terminated state, display notification
  if (message.notification == null) {
    final title = message.data['title']?.toString() ?? 'KOMPASS Alert';
    final body = message.data['body']?.toString() ?? '';
    if (body.isNotEmpty) {
      final localNotifications = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await localNotifications.initialize(const InitializationSettings(android: androidInit));
      const androidDetails = AndroidNotificationDetails(
        'kompass_chat_channel',
        'KOMPASS Expedition Radio',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      await localNotifications.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(android: androidDetails),
        payload: message.data['tourId']?.toString(),
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for consistent UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background push message handler (native only; web handled by firebase-messaging-sw.js)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await HiveService.instance.initialize();

  // Initialize FCM push notifications (gracefully handle web/emulator limitations)
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService init skipped or failed: $e');
  }

  runApp(
    const ProviderScope(
      child: KompassApp(),
    ),
  );
}
