import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../../core/constants/zego_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';

/// Screen for real-time Tour Voice Broadcast and Audio Commentary.
///
/// Enables Tour Guides to broadcast commentary directly to all connected pilgrims/participants.
/// Participants join with speaker enabled, muted by default to prevent ambient noise,
/// and can unmute at any time to ask questions or speak.
class TourVoiceRoomScreen extends ConsumerWidget {
  final String tourId;

  const TourVoiceRoomScreen({
    super.key,
    required this.tourId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final tourAsync = ref.watch(tourDetailProvider(tourId));

    if (currentUser == null) {
      return Scaffold(
        appBar: const KompassAppBar(title: 'Live Audio Tour'),
        body: Center(
          child: Text(
            'Please sign in to join the voice tour channel.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    return tourAsync.when(
      loading: () => const Scaffold(
        appBar: KompassAppBar(title: 'Live Audio Tour'),
        body: Center(
          child: KompassLoading(message: 'Connecting to Tour Audio Channel...'),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: const KompassAppBar(title: 'Live Audio Tour'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Could not load tour details: $err',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (tour) {
        final isGuide = tour.canManageTour(currentUser.userId) ||
            currentUser.userRole == UserRole.guide ||
            currentUser.userRole == UserRole.admin;

        final callId = ZegoConstants.tourVoiceRoomId(tourId);
        final safeUserId = ZegoConstants.sanitizeId(currentUser.userId);
        final safeUserName = currentUser.name.isNotEmpty
            ? currentUser.name
            : 'Pilgrim_${safeUserId.length > 4 ? safeUserId.substring(0, 4) : safeUserId}';

        final config = ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
          ..turnOnCameraWhenJoining = false
          ..turnOnMicrophoneWhenJoining = isGuide
          ..useSpeakerWhenJoining = true
          ..topMenuBar.isVisible = true
          ..topMenuBar.title = '${tour.name} (Voice Commentary)'
          ..bottomMenuBar.buttons = [
            ZegoCallMenuBarButtonName.toggleMicrophoneButton,
            ZegoCallMenuBarButtonName.switchAudioOutputButton,
            ZegoCallMenuBarButtonName.showMemberListButton,
            ZegoCallMenuBarButtonName.hangUpButton,
          ]
          ..memberList.showMicrophoneState = true
          ..memberList.showCameraState = false
          ..foreground = Positioned(
            top: 70,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isGuide
                    ? AppColors.primaryGold.withAlpha(230)
                    : AppColors.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isGuide ? AppColors.primaryGold : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isGuide ? Icons.record_voice_over : Icons.headphones,
                    size: 18,
                    color: isGuide ? Colors.black : AppColors.primaryGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGuide
                          ? 'Guide Broadcast Active • Tap mic to mute/unmute'
                          : 'Listening to Guide commentary • Tap mic to speak',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isGuide ? Colors.black : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );

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
      },
    );
  }
}
