/// Web Notification Permission states.
enum WebNotificationPermission {
  granted,
  denied,
  defaultState,
  notSupported,
}

/// Stub implementation of WebNotificationHelper for non-web platforms.
class WebNotificationHelper {
  static bool get isSupported => false;

  static WebNotificationPermission get permission =>
      WebNotificationPermission.notSupported;

  static Future<WebNotificationPermission> requestPermission() async {
    return WebNotificationPermission.notSupported;
  }

  static void showWebNotification({
    required String title,
    required String body,
    String? tag,
    String? payload,
    bool requireInteraction = false,
    void Function(String? payload)? onClick,
  }) {}

  static void playNotificationChime({bool isEmergency = false}) {}
}
