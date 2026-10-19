/// ZEGOCloud RTC configuration and room ID helpers for KOMPASS.
///
/// To obtain your AppID and AppSign:
/// 1. Sign up / Log in to ZEGOCloud Console: https://console.zegocloud.com
/// 2. Create a project with "Voice & Video Call" or "Live Audio".
/// 3. Copy your AppID (integer) and AppSign (64-char hex string) and paste them here
///    or pass via `--dart-define=ZEGO_APP_ID=...` and `--dart-define=ZEGO_APP_SIGN=...`.
class ZegoConstants {
  ZegoConstants._();

  /// Default ZEGOCloud AppID.
  /// Can be overridden via compile-time `--dart-define=ZEGO_APP_ID=...`.
  static const int appID = int.fromEnvironment(
    'ZEGO_APP_ID',
    defaultValue: 1981335340,
  );

  /// Default ZEGOCloud AppSign.
  /// Can be overridden via compile-time `--dart-define=ZEGO_APP_SIGN=...`.
  static const String appSign = String.fromEnvironment(
    'ZEGO_APP_SIGN',
    defaultValue:
        '159e48417b949caade247a19eb174bdee5f81b916851cd74dce5e760423d0701',
  );

  /// Sanitize an arbitrary string (tourId, userId, alertId) to match ZEGO room ID requirements.
  /// ZEGO requires ASCII letters, numbers, and underscores, max 64 characters.
  static String sanitizeId(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (clean.length > 55) {
      return clean.substring(0, 55);
    }
    return clean;
  }

  /// Generate a unique CallID for a tour's live group audio commentary room.
  static String tourVoiceRoomId(String tourId) {
    return 'tour_${sanitizeId(tourId)}';
  }

  /// Generate a unique CallID for an emergency SOS voice/video call.
  static String sosCallId(String alertId) {
    return 'sos_${sanitizeId(alertId)}';
  }

  /// Generate a deterministic 1-on-1 direct call ID between two users.
  static String directCallId(String userIdA, String userIdB) {
    final sorted = [sanitizeId(userIdA), sanitizeId(userIdB)]..sort();
    return 'p2p_${sorted[0]}_${sorted[1]}';
  }
}
