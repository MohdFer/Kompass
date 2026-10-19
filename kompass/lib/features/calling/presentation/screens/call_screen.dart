import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../../core/constants/zego_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../auth/providers/auth_providers.dart';

/// Screen for 1-on-1 Voice or Video Calls.
///
/// Used for:
/// 1. Emergency SOS distress call (audio or video verification with guide/responders).
/// 2. Direct calling between Tour Guide and specific participants.
class CallScreen extends ConsumerWidget {
  final String callId;
  final String targetUserName;
  final bool isVideo;
  final bool isEmergency;

  const CallScreen({
    super.key,
    required this.callId,
    required this.targetUserName,
    this.isVideo = false,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (currentUser == null) {
      return Scaffold(
        appBar: KompassAppBar(
          title: isEmergency ? 'Emergency SOS Call' : 'Direct Call',
        ),
        body: Center(
          child: Text(
            'Please log in to initiate or receive calls.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final safeUserId = ZegoConstants.sanitizeId(currentUser.userId);
    final safeUserName = currentUser.name.isNotEmpty
        ? currentUser.name
        : 'User_${safeUserId.length > 4 ? safeUserId.substring(0, 4) : safeUserId}';

    final config = isVideo
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    config
      ..turnOnCameraWhenJoining = isVideo
      ..turnOnMicrophoneWhenJoining = true
      ..useSpeakerWhenJoining = true
      ..topMenuBar.isVisible = true
      ..topMenuBar.title = isEmergency
          ? '🚨 SOS: $targetUserName'
          : (isVideo ? 'Video Call: $targetUserName' : 'Voice Call: $targetUserName');

    if (!isVideo) {
      config.bottomMenuBar.buttons = [
        ZegoCallMenuBarButtonName.toggleMicrophoneButton,
        ZegoCallMenuBarButtonName.switchAudioOutputButton,
        ZegoCallMenuBarButtonName.hangUpButton,
      ];
    }

    if (isEmergency) {
      config.foreground = Positioned(
        top: 70,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(230),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.redAccent),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CRITICAL EMERGENCY CALL • Audio/Video Connected',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: ZegoConstants.appID,
        appSign: ZegoConstants.appSign,
        userID: safeUserId,
        userName: safeUserName,
        callID: callId,
        config: config,
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (event, defaultAction) {
            defaultAction.call();
          },
        ),
      ),
    );
  }
}
