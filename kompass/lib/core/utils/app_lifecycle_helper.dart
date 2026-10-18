import 'package:flutter/services.dart';

/// Helper for native Android app lifecycle operations.
class AppLifecycleHelper {
  AppLifecycleHelper._();

  static const MethodChannel _channel =
      MethodChannel('com.kompass.kompass/app_lifecycle');

  /// Sends the app to the background via Android's moveTaskToBack(true),
  /// matching the exact behavior of the physical/virtual Home button.
  ///
  /// This keeps the Flutter engine, process memory, and background listeners intact.
  static Future<void> sendToBackground() async {
    try {
      await _channel.invokeMethod('sendToBackground');
    } catch (_) {
      // Fallback on web or platforms where MethodChannel is not available
      SystemNavigator.pop();
    }
  }
}
