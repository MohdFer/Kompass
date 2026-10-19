import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../../core/constants/zego_constants.dart';
import '../../core/utils/app_toast.dart';
import '../../features/auth/providers/auth_providers.dart';

/// Centralized service managing ZEGOCloud Call Invitations (Ringing, Accept, Decline).
///
/// Features:
/// 1. Outgoing call ringtone & invitation dispatch.
/// 2. Incoming call banner/dialog with Accept (attend) & Decline actions.
/// 3. Automatic connection to one-on-one voice or video session upon acceptance.
/// 4. Graceful web fallback guard (kIsWeb).
class ZegoCallService {
  ZegoCallService._();
  static final instance = ZegoCallService._();

  bool _isInitialized = false;
  String? _activeUserId;

  /// Registers the root NavigatorKey to allow incoming call popups across any screen.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    if (kIsWeb) return;
    try {
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    } catch (e) {
      debugPrint('[ZEGO] Error setting navigator key: $e');
    }
  }

  /// Initializes the signaling & invitation listener when a user authenticates.
  Future<void> onUserLogin({
    required String userId,
    required String userName,
  }) async {
    if (kIsWeb) return;

    final safeUserId = ZegoConstants.sanitizeId(userId);
    final safeUserName = userName.trim().isNotEmpty
        ? userName.trim()
        : 'User_${safeUserId.length > 4 ? safeUserId.substring(0, 4) : safeUserId}';

    if (_isInitialized && _activeUserId == safeUserId) {
      return;
    }

    try {
      if (_isInitialized) {
        await ZegoUIKitPrebuiltCallInvitationService().uninit();
        _isInitialized = false;
      }

      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: ZegoConstants.appID,
        appSign: ZegoConstants.appSign,
        userID: safeUserId,
        userName: safeUserName,
        plugins: [ZegoUIKitSignalingPlugin()],
        requireConfig: (ZegoCallInvitationData data) {
          final isVideo = data.type == ZegoCallInvitationType.videoCall;
          final config = isVideo
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

          config
            ..turnOnMicrophoneWhenJoining = true
            ..useSpeakerWhenJoining = true
            ..topMenuBar.isVisible = true;

          return config;
        },
      );

      _isInitialized = true;
      _activeUserId = safeUserId;
      debugPrint('[ZEGO] Call Invitation Service initialized for $safeUserName ($safeUserId)');
    } catch (e) {
      debugPrint('[ZEGO] Error initializing Call Invitation Service: $e');
    }
  }

  /// Tears down the signaling listener on user logout.
  Future<void> onUserLogout() async {
    if (kIsWeb) return;
    if (!_isInitialized) return;

    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      _isInitialized = false;
      _activeUserId = null;
      debugPrint('[ZEGO] Call Invitation Service uninitialized');
    } catch (e) {
      debugPrint('[ZEGO] Error uninitializing Call Invitation Service: $e');
    }
  }

  /// Sends a 1-on-1 VoIP call invitation.
  ///
  /// This plays an outgoing ringtone on caller's phone and rings the receiver's phone.
  /// Call only connects once the callee presses 'Accept'.
  Future<bool> sendCallInvitation({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    required bool isVideo,
  }) async {
    if (kIsWeb) {
      AppToast.showInfo('In-app calling is supported on KOMPASS Android & iOS.');
      return false;
    }

    if (!_isInitialized) {
      AppToast.showError('Calling service is connecting. Please try again shortly.', context: context);
      return false;
    }

    final safeTargetId = ZegoConstants.sanitizeId(targetUserId);
    final safeTargetName = targetUserName.trim().isNotEmpty
        ? targetUserName.trim()
        : 'User_${safeTargetId.length > 4 ? safeTargetId.substring(0, 4) : safeTargetId}';

    try {
      final success = await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(safeTargetId, safeTargetName)],
        isVideoCall: isVideo,
        timeoutSeconds: 60,
      );

      if (!success && context.mounted) {
        AppToast.showError('Could not send call invitation to $safeTargetName', context: context);
      }
      return success;
    } catch (e) {
      debugPrint('[ZEGO] Error sending call invitation: $e');
      if (context.mounted) {
        AppToast.showError('Failed to initiate call: $e', context: context);
      }
      return false;
    }
  }
}

/// Riverpod coordinator provider that binds user authentication state to the ZEGO Call Invitation Service.
final zegoCallCoordinatorProvider = Provider<void>((ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  if (currentUser != null) {
    ZegoCallService.instance.onUserLogin(
      userId: currentUser.userId,
      userName: currentUser.name,
    );
  } else {
    ZegoCallService.instance.onUserLogout();
  }
});
