import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_lifecycle_helper.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../location/providers/location_providers.dart';
import '../../../../services/permissions/app_permission_service.dart';
import '../../../tour/data/models/tour_model.dart';
import '../../../tour/providers/tour_providers.dart';

class ParticipantDashboardScreen extends ConsumerWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final user = userState.valueOrNull;
    final userName = user?.name ?? 'Explorer';
    final toursAsync = ref.watch(toursProvider);
    final gpsStatus = ref.watch(gpsStatusProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        if (kIsWeb) {
          AppPermissionService.instance.checkAndPromptWebNotifications(context: context);
        } else {
          AppPermissionService.instance.checkAndPromptBatteryOptimization(context: context);
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        AppLifecycleHelper.sendToBackground();
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('KOMPASS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: toursAsync.when(
        data: (allTours) {
          // 1. Tours where this user received an email invite from the Tour Guide
          final invitedTours = user == null
              ? <TourModel>[]
              : allTours
                  .where(
                    (t) =>
                        t.invitedUserIds.contains(user.userId) &&
                        !t.participantIds.contains(user.userId),
                  )
                  .toList();

          // 2. Tours where this user sent a join request and is waiting for Guide approval
          final pendingRequestedTours = user == null
              ? <TourModel>[]
              : allTours
                  .where(
                    (t) =>
                        t.pendingRequestUserIds.contains(user.userId) &&
                        !t.participantIds.contains(user.userId),
                  )
                  .toList();

          // 3. Tours created/guided by this user
          final guidedTours = user == null
              ? <TourModel>[]
              : allTours.where((t) => t.guideId == user.userId).toList();

          // 4. Tours where this user joined as a participant (and isn't the creator)
          final joinedTours = user == null
              ? <TourModel>[]
              : allTours
                  .where(
                    (t) =>
                        t.participantIds.contains(user.userId) &&
                        t.guideId != user.userId,
                  )
                  .toList();

          // 5. Public tours available to browse & join directly
          final availablePublicTours = user == null
              ? <TourModel>[]
              : allTours
                  .where(
                    (t) =>
                        t.isPublic &&
                        t.guideId != user.userId &&
                        !t.participantIds.contains(user.userId) &&
                        !t.pendingRequestUserIds.contains(user.userId),
                  )
                  .toList();

          return RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              ref.invalidate(currentUserProvider);
              ref.invalidate(allUsersProvider);
              ref.invalidate(toursProvider);
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                if (gpsStatus.isGpsDisabledWhenRequired) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off_rounded, color: AppColors.primaryGold, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GPS Location is Turned Off',
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryGold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tour tracking is required and location sharing is active. Please turn on Location in Settings.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Geolocator.openLocationSettings(),
                          child: const Text('Turn On', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
                Text('Welcome, $userName!', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: KompassButton(
                      label: 'Create Tour',
                      icon: Icons.add_location_alt,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      onPressed: () => context.push('/tours/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KompassButton(
                      label: 'Join Tour',
                      icon: Icons.group_add,
                      isOutlined: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      onPressed: user == null
                          ? null
                          : () => _showJoinTourDialog(
                                context,
                                ref,
                                user.userId,
                                availablePublicTours,
                              ),
                    ),
                  ),
                ],
              ),

              // ── Tour Invitations Section (Sent via Email by a Tour Guide) ──
              if (invitedTours.isNotEmpty && user != null) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColors.primaryGold,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tour Invitations (${invitedTours.length})',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...invitedTours.map(
                  (tour) => KompassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    borderColor: AppColors.primaryGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tour.name, style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 4),
                        Text(tour.description, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 6),
                        Text(
                          'You were invited by the Tour Guide to join this expedition.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryGoldLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                minimumSize: const Size(90, 38),
                              ),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(tourControllerProvider.notifier)
                                      .respondToInvite(
                                        tour.tourId,
                                        user.userId,
                                        accept: false,
                                      );
                                  AppToast.showInfo(
                                    'Declined invitation to "${tour.name}".',
                                  );
                                } catch (e) {
                                  AppToast.showError('Failed to decline invitation: $e');
                                }
                              },
                              child: const Text('Decline'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                minimumSize: const Size(120, 38),
                              ),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(tourControllerProvider.notifier)
                                      .respondToInvite(
                                        tour.tourId,
                                        user.userId,
                                        accept: true,
                                      );
                                  AppToast.showSuccess(
                                    'Accepted invitation! You joined "${tour.name}".',
                                  );
                                } catch (e) {
                                  AppToast.showError('Failed to accept invitation: $e');
                                }
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Accept Invite'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Pending Join Requests Section (Waiting for Guide Approval) ──
              if (pendingRequestedTours.isNotEmpty && user != null) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Join Requests (${pendingRequestedTours.length})',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...pendingRequestedTours.map(
                  (tour) => KompassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.schedule,
                        color: AppColors.warning,
                      ),
                      title: Text(
                        tour.name,
                        style: AppTextStyles.headlineMedium,
                      ),
                      subtitle: const Text(
                        'Awaiting Tour Guide approval to admit you into this tour',
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(tourControllerProvider.notifier)
                                .respondToJoinRequest(
                                  tour.tourId,
                                  user.userId,
                                  approve: false,
                                );
                            AppToast.showInfo(
                              'Cancelled join request for "${tour.name}".',
                            );
                          } catch (e) {
                            AppToast.showError('Failed to cancel request: $e');
                          }
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),
              Row(
                children: [
                  const Icon(
                    Icons.compass_calibration,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tours I\'m Guiding (${guidedTours.length})',
                    style: AppTextStyles.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (guidedTours.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'You haven\'t created any tours yet. Tap "Create Tour" above to lead an expedition!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                )
              else
                ...guidedTours.map(
                  (tour) => KompassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    borderColor: tour.pendingRequestUserIds.isNotEmpty
                        ? AppColors.warning
                        : null,
                    onTap: () => context.push('/tours/${tour.tourId}'),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tour.name,
                        style: AppTextStyles.headlineMedium,
                      ),
                      subtitle: Text(
                        '${tour.description}\n'
                        '${tour.isPublic ? 'Public' : 'Private (Code Only)'} • '
                        '${tour.requireJoinApproval ? 'Approval Required' : 'Auto-Admit'} • '
                        '${tour.participantCount} Participants'
                        '${tour.pendingRequestUserIds.isNotEmpty ? '\n🔔 ${tour.pendingRequestUserIds.length} Pending Join Request(s) — Tap to review' : ''}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete Tour',
                        onPressed: () => _confirmDeleteTour(context, ref, tour),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.hiking,
                    color: AppColors.secondaryTealLight,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tours I\'ve Joined (${joinedTours.length})',
                    style: AppTextStyles.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (joinedTours.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'You haven\'t joined any tours as a participant yet. Tap "Join Tour" to browse public tours or enter a Tour Code!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                )
              else
                ...joinedTours.map(
                  (tour) => KompassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    onTap: () => context.push('/tours/${tour.tourId}'),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tour.name,
                        style: AppTextStyles.headlineMedium,
                      ),
                      subtitle: Text(tour.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(tour.status),
                            backgroundColor: AppColors.surfaceVariant,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: AppColors.error,
                              size: 20,
                            ),
                            tooltip: 'Leave Tour',
                            onPressed: user == null
                                ? null
                                : () => _confirmLeaveTour(
                                      context,
                                      ref,
                                      tour,
                                      user.userId,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            ref.invalidate(toursProvider);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(child: Text('Error loading tours: $e')),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void _confirmLeaveTour(
    BuildContext context,
    WidgetRef ref,
    TourModel tour,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Leave Tour'),
          content: Text(
            'Are you sure you want to leave "${tour.name}"?\n\n'
            'You will no longer be an active participant in this expedition.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await ref
                      .read(tourControllerProvider.notifier)
                      .removeParticipant(tour.tourId, userId);
                  AppToast.showSuccess('You have left "${tour.name}".');
                } catch (e) {
                  AppToast.showError('Failed to leave tour: $e');
                }
              },
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTour(
    BuildContext context,
    WidgetRef ref,
    TourModel tour,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Tour?'),
          content: Text(
            'Are you sure you want to permanently delete "${tour.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await ref
                      .read(tourControllerProvider.notifier)
                      .deleteTour(tour.tourId);
                  AppToast.showSuccess('Tour "${tour.name}" deleted successfully.');
                } catch (e) {
                  AppToast.showError('Failed to delete tour: $e');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinTourDialog(
    BuildContext parentContext,
    WidgetRef ref,
    String userId,
    List<TourModel> availablePublicTours,
  ) {
    final codeController = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Join a Tour'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Have a Private or Public Tour Code?',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Tour Code',
                      hintText: 'Paste Tour Code from your Guide',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Available Public Tours',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  if (availablePublicTours.isEmpty)
                    Text(
                      'No public tours available right now. Enter a Tour Code above to join a private tour.',
                      style: AppTextStyles.bodySmall,
                    )
                  else
                    ...availablePublicTours.map(
                      (tour) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tour.name),
                        subtitle: Text(
                          '${tour.description}\n'
                          '${tour.requireJoinApproval ? 'Requires Guide Approval' : 'Instant Admission'} • ${tour.status}',
                        ),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(86, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () async {
                            try {
                              final resultTour = await ref
                                  .read(tourControllerProvider.notifier)
                                  .requestOrJoinTour(tour.tourId, userId);
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                              final isPending = resultTour.pendingRequestUserIds
                                  .contains(userId);
                              if (isPending) {
                                AppToast.showInfo(
                                  'Join request sent for "${resultTour.name}"! Waiting for Tour Guide approval.',
                                );
                              } else {
                                AppToast.showSuccess(
                                  'Successfully joined "${resultTour.name}"!',
                                );
                              }
                            } catch (e) {
                              final cleanMsg =
                                  e.toString().replaceFirst('Exception: ', '');
                              AppToast.showError('Failed to join tour: $cleanMsg');
                            }
                          },
                          child: Text(
                            tour.requireJoinApproval ? 'Request' : 'Join',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final codeInput = codeController.text.trim();
                if (codeInput.isEmpty) {
                  AppToast.showWarning('Please enter a Tour Code first.');
                  return;
                }
                try {
                  final resultTour = await ref
                      .read(tourControllerProvider.notifier)
                      .joinTourByCode(codeInput, userId);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  final isPending =
                      resultTour.pendingRequestUserIds.contains(userId);
                  if (isPending) {
                    AppToast.showInfo(
                      'Join request sent for "${resultTour.name}"! Waiting for Tour Guide to accept.',
                    );
                  } else {
                    AppToast.showSuccess(
                      'Successfully joined "${resultTour.name}"!',
                    );
                  }
                } catch (e) {
                  final cleanMsg = e.toString().replaceFirst('Exception: ', '');
                  AppToast.showError('Failed to join with code: $cleanMsg');
                }
              },
              child: const Text('Enter with Code'),
            ),
          ],
        );
      },
    );
  }
}
