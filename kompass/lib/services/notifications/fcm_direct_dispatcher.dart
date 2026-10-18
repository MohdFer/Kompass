import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Service that directly signs and dispatches high-priority push notifications to Google FCM HTTP v1
/// using the project's Service Account credentials.
///
/// This provides 100% free background push notifications on the Firebase Spark Plan
/// without requiring Cloud Functions or the Blaze plan!
class FcmDirectDispatcher {
  FcmDirectDispatcher._();
  static final instance = FcmDirectDispatcher._();

  String? _projectId;
  String? _clientEmail;
  RsaPrivateKey? _rsaKey;
  String? _tokenUri;

  String? _cachedAccessToken;
  DateTime? _tokenExpiry;
  bool _isInitialized = false;

  /// Load and initialize Service Account credentials from assets.
  Future<bool> initialize() async {
    if (_isInitialized && _rsaKey != null) return true;

    try {
      final jsonStr = await rootBundle.loadString('assets/service_account.json');
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;

      _projectId = jsonMap['project_id'] as String?;
      _clientEmail = jsonMap['client_email'] as String?;
      final privateKeyPem = jsonMap['private_key'] as String?;
      _tokenUri = (jsonMap['token_uri'] as String?) ?? 'https://oauth2.googleapis.com/token';

      if (_clientEmail == null || privateKeyPem == null || _projectId == null) {
        debugPrint('FcmDirectDispatcher: Missing required service account fields.');
        return false;
      }

      _rsaKey = RsaPrivateKey.fromPem(privateKeyPem);
      _isInitialized = true;
      debugPrint('FcmDirectDispatcher: Successfully initialized for project $_projectId');
      return true;
    } catch (e) {
      debugPrint('FcmDirectDispatcher init error: $e');
      return false;
    }
  }

  /// Get or refresh a valid short-lived Google OAuth2 access token.
  Future<String?> _getAccessToken() async {
    final now = DateTime.now().toUtc();
    if (_cachedAccessToken != null && _tokenExpiry != null && now.isBefore(_tokenExpiry!)) {
      return _cachedAccessToken;
    }

    final ready = await initialize();
    if (!ready || _rsaKey == null || _clientEmail == null || _tokenUri == null) {
      return null;
    }

    try {
      final iat = now.millisecondsSinceEpoch ~/ 1000;
      final exp = iat + 3600;

      final header = {'alg': 'RS256', 'typ': 'JWT'};
      final claimSet = {
        'iss': _clientEmail,
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': _tokenUri,
        'iat': iat,
        'exp': exp,
      };

      final encHeader = _base64UrlNoPad(utf8.encode(jsonEncode(header)));
      final encClaimSet = _base64UrlNoPad(utf8.encode(jsonEncode(claimSet)));
      final signingInput = '$encHeader.$encClaimSet';

      final sig = _rsaKey!.signSha256(utf8.encode(signingInput));
      final encSig = _base64UrlNoPad(sig);
      final jwt = '$signingInput.$encSig';

      final response = await http.post(
        Uri.parse(_tokenUri!),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jwt',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _cachedAccessToken = data['access_token'] as String?;
        final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
        _tokenExpiry = now.add(Duration(seconds: expiresIn - 120)); // renew 2 mins early
        return _cachedAccessToken;
      } else {
        debugPrint('FcmDirectDispatcher: OAuth token error [${response.statusCode}]: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('FcmDirectDispatcher: Failed to get OAuth token: $e');
      return null;
    }
  }

  /// Send a high-priority push notification to all devices subscribed to tour_{tourId}.
  /// Send a high-priority push notification to all devices subscribed to tour_{tourId}.
  Future<bool> sendTourNotification({
    required String tourId,
    required String title,
    required String body,
    required String type,
    String? senderId,
    String? messageId,
    Map<String, String>? extraData,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null || _projectId == null) {
        debugPrint('FcmDirectDispatcher: Token not available, skipping background FCM push.');
        return false;
      }

      final fcmEndpoint = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );

      final messagePayload = {
        'message': {
          'topic': 'tour_$tourId',
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'title': title,
            'body': body,
            'tourId': tourId,
            'type': type,
            if (senderId != null) 'senderId': senderId,
            if (messageId != null) 'messageId': messageId,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            ...?extraData,
          },
          'android': {
            'priority': 'HIGH',
            'notification': {
              'channel_id': 'kompass_chat_channel',
              'sound': 'default',
              'notification_priority': 'PRIORITY_MAX',
              'visibility': 'PUBLIC',
              'default_sound': true,
              'default_vibrate_timings': true,
            },
          },
        },
      };

      final response = await http.post(
        fcmEndpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; UTF-8',
        },
        body: jsonEncode(messagePayload),
      );

      if (response.statusCode == 200) {
        debugPrint('FcmDirectDispatcher: Push delivered to topic tour_$tourId ($type)');
        return true;
      } else {
        debugPrint('FcmDirectDispatcher: Push failed [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('FcmDirectDispatcher: Error sending push: $e');
      return false;
    }
  }

  /// Dispatch chat message push notification to all tour members.
  Future<void> sendChatMessage({
    required String tourId,
    required String tourName,
    required String senderName,
    required String messageText,
    String? senderId,
    String? messageId,
  }) async {
    await sendTourNotification(
      tourId: tourId,
      title: '💬 $senderName ($tourName)',
      body: messageText,
      type: 'chat',
      senderId: senderId,
      messageId: messageId,
    );
  }

  /// Dispatch broadcast announcement push notification to all tour members.
  Future<void> sendAnnouncement({
    required String tourId,
    required String tourName,
    required String title,
    required String messageText,
    String? senderId,
    String? announcementId,
  }) async {
    await sendTourNotification(
      tourId: tourId,
      title: '📢 $title ($tourName)',
      body: messageText,
      type: 'announcement',
      senderId: senderId,
      messageId: announcementId,
    );
  }

  /// Dispatch emergency SOS distress push notification with highest priority.
  Future<void> sendSosDistress({
    required String tourId,
    required String tourName,
    required String userName,
    required String reason,
    String? senderId,
    String? alertId,
    double? latitude,
    double? longitude,
  }) async {
    final coordsText = (latitude != null && longitude != null && (latitude != 0 || longitude != 0))
        ? ' • GPS: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'
        : '';

    await sendTourNotification(
      tourId: tourId,
      title: '🚨 EMERGENCY SOS: $userName',
      body: '$reason$coordsText',
      type: 'sos',
      senderId: senderId,
      messageId: alertId,
      extraData: {
        'latitude': latitude?.toString() ?? '0.0',
        'longitude': longitude?.toString() ?? '0.0',
      },
    );
  }

  static String _base64UrlNoPad(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}

/// ASN.1 DER parser for extracting modulus and private exponent from PKCS#8 RSA key
class RsaPrivateKey {
  final BigInt modulus;
  final BigInt privateExponent;

  RsaPrivateKey(this.modulus, this.privateExponent);

  static RsaPrivateKey fromPem(String pem) {
    final clean = pem
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();
    final bytes = base64Decode(clean);
    return _parsePkcs8(bytes);
  }

  static RsaPrivateKey _parsePkcs8(Uint8List bytes) {
    int offset = 0;

    void expect(int expected) {
      if (bytes[offset++] != expected) throw const FormatException('Invalid ASN.1');
    }

    int readLength() {
      int len = bytes[offset++];
      if ((len & 0x80) != 0) {
        final count = len & 0x7F;
        len = 0;
        for (int i = 0; i < count; i++) {
          len = (len << 8) | bytes[offset++];
        }
      }
      return len;
    }

    BigInt readInteger() {
      expect(0x02);
      final len = readLength();
      final intBytes = bytes.sublist(offset, offset + len);
      offset += len;
      return _bytesToBigInt(intBytes);
    }

    // Sequence (PKCS#8 outer)
    expect(0x30);
    readLength();
    // Version
    readInteger();
    // AlgorithmIdentifier Sequence
    expect(0x30);
    final algLen = readLength();
    offset += algLen;
    // OctetString (wrapped PKCS#1 key)
    expect(0x04);
    readLength();

    // Inside PKCS#1 RSAPrivateKey Sequence
    expect(0x30);
    readLength();
    // Version
    readInteger();
    // Modulus (n)
    final n = readInteger();
    // Public exponent (e)
    readInteger();
    // Private exponent (d)
    final d = readInteger();

    return RsaPrivateKey(n, d);
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (int b in bytes) {
      result = (result << 8) | BigInt.from(b);
    }
    return result;
  }

  Uint8List signSha256(Uint8List messageBytes) {
    final hash = sha256.convert(messageBytes).bytes;
    // PKCS#1 v1.5 DigestInfo header for SHA-256
    final digestInfo = [
      0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20,
      ...hash,
    ];

    final k = (modulus.bitLength + 7) ~/ 8;
    final psLen = k - digestInfo.length - 3;
    if (psLen < 8) throw StateError('Modulus too short');

    final em = <int>[
      0x00,
      0x01,
      ...List.filled(psLen, 0xFF),
      0x00,
      ...digestInfo,
    ];

    final m = _bytesToBigInt(Uint8List.fromList(em));
    final s = m.modPow(privateExponent, modulus);

    String hex = s.toRadixString(16);
    if (hex.length % 2 != 0) hex = '0$hex';
    final sigBytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      sigBytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    while (sigBytes.length < k) {
      sigBytes.insert(0, 0);
    }
    return Uint8List.fromList(sigBytes);
  }
}
