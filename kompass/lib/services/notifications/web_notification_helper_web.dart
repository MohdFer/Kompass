import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'web_notification_helper_stub.dart';

export 'web_notification_helper_stub.dart' show WebNotificationPermission;

/// Web implementation of WebNotificationHelper utilizing modern Web Notification & Web Audio APIs.
class WebNotificationHelper {
  static bool get isSupported {
    try {
      final _ = web.Notification.permission;
      return true;
    } catch (_) {
      return false;
    }
  }

  static WebNotificationPermission get permission {
    try {
      final perm = web.Notification.permission;
      if (perm == 'granted') return WebNotificationPermission.granted;
      if (perm == 'denied') return WebNotificationPermission.denied;
      return WebNotificationPermission.defaultState;
    } catch (_) {
      return WebNotificationPermission.notSupported;
    }
  }

  static Future<WebNotificationPermission> requestPermission() async {
    try {
      final promise = web.Notification.requestPermission();
      final jsStr = await promise.toDart;
      final result = jsStr.toDart;
      debugPrint('WebNotificationHelper: permission request result = $result');
      if (result == 'granted') return WebNotificationPermission.granted;
      if (result == 'denied') return WebNotificationPermission.denied;
      return WebNotificationPermission.defaultState;
    } catch (e) {
      debugPrint('WebNotificationHelper: requestPermission failed: $e');
      return WebNotificationPermission.notSupported;
    }
  }

  static void showWebNotification({
    required String title,
    required String body,
    String? tag,
    String? payload,
    bool requireInteraction = false,
    void Function(String? payload)? onClick,
  }) {
    try {
      if (permission != WebNotificationPermission.granted) {
        debugPrint('WebNotificationHelper: permission not granted, skipping notification');
        return;
      }

      final options = web.NotificationOptions(
        body: body,
        icon: 'icons/Icon-192.png',
        badge: 'favicon.png',
        tag: tag ?? '',
        requireInteraction: requireInteraction,
      );

      final notif = web.Notification(title, options);
      if (onClick != null) {
        notif.onclick = ((web.Event _) {
          try {
            web.window.focus();
          } catch (_) {}
          onClick(payload);
        }).toJS;
      }
    } catch (e) {
      debugPrint('WebNotificationHelper: Error showing web notification: $e');
    }
  }

  static void playNotificationChime({bool isEmergency = false}) {
    try {
      final ctx = web.AudioContext();
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);

      final double freq = isEmergency ? 880.0 : 587.33; // D5 pleasant chime / A5 emergency
      final double duration = isEmergency ? 0.6 : 0.35;

      osc.frequency.setValueAtTime(freq, ctx.currentTime);
      gain.gain.setValueAtTime(0.18, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(
        0.0001,
        ctx.currentTime + duration,
      );

      osc.start(ctx.currentTime);
      osc.stop(ctx.currentTime + duration);
    } catch (_) {}
  }
}
