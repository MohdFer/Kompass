import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notifications/notification_service.dart';
import 'services/storage/hive_service.dart';

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
