import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/enums/tour_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';

class TourDetailScreen extends ConsumerWidget {
  final String tourId;
  const TourDetailScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourDetailProvider(tourId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final allUsers = ref.watch(allUsersProvider).valueOrNull ?? [];

    return tourAsync.when(
      data: (tour) {
        final isAdmin = currentUser?.isAdmin == true;
        final isPrimaryGuide = currentUser != null &&
            (tour.isPrimaryGuide(currentUser.userId) || isAdmin);
        final isGuestGuide = currentUser != null &&
            tour.isGuestGuide(currentUser.userId);
        final canManageTour = currentUser != null &&
            (tour.canManageTour(currentUser.userId) || isAdmin);
        final guideUser = allUsers
            .where((u) => u.userId == tour.guideId)
            .firstOrNull;
        final guestGuideNames = allUsers
            .where((u) => tour.guestGuideIds.contains(u.userId))
            .map((u) => u.name)
            .toList();

        return Scaffold(
          appBar: KompassAppBar(
            title: 'Tour Details',
            actions: [
              if (canManageTour) ...[
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.group_add),
                      tooltip: 'Invite by Email & Manage Participants',
                      onPressed: () => _showManageParticipantsSheet(
                        context,
                        ref,
                        tour,
                        allUsers,
                        isPrimaryGuide: isPrimaryGuide,
                        currentUser: currentUser,
                      ),
                    ),
                    if (tour.pendingRequestUserIds.isNotEmpty)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${tour.pendingRequestUserIds.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (isPrimaryGuide) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Tour & Settings',
                  onPressed: () => _showEditTourDialog(context, ref, tour),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  tooltip: 'Delete Tour',
                  onPressed: () => _confirmDeleteTour(context, ref, tour),
                ),
              ] else if (currentUser != null &&
                  tour.participantIds.contains(currentUser.userId)) ...[
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                  ),
                  tooltip: 'Leave Tour',
                  onPressed: () => _confirmLeaveTour(
                    context,
                    ref,
                    tour,
                    currentUser.userId,
                  ),
                ),
              ],
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              ref.invalidate(tourDetailProvider(tourId));
              ref.invalidate(allUsersProvider);
              ref.invalidate(currentUserProvider);
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                KompassCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tour.name,
                            style: AppTextStyles.displayMedium,
                          ),
                        ),
                        Chip(
                          label: Text(tour.status),
                          backgroundColor: tour.isActive
                              ? AppColors.success.withValues(alpha: 0.25)
                              : AppColors.surfaceVariant,
                        ),
                      ],
                    ),
                    if (isGuestGuide) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 15,
                              color: AppColors.primaryGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'You are a Guest Guide for this tour',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tour.isPublic ? Icons.public : Icons.lock_outline,
                              size: 16,
                              color: AppColors.primaryGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tour.isPublic
                                  ? 'Public Tour'
                                  : 'Private Tour (Code Only)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryGold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tour.requireJoinApproval
                                  ? Icons.how_to_reg_outlined
                                  : Icons.bolt_outlined,
                              size: 16,
                              color: AppColors.secondaryTealLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.requireJoinApproval
                                  ? 'Code Join: Requires Guide Approval'
                                  : 'Code Join: Auto-Admit',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryTealLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(tour.description, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    if (tour.startDate != null && tour.endDate != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.primaryGold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${tour.startDate.toString().split(' ')[0]} → ${tour.endDate.toString().split(' ')[0]}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tour Guide: ${guideUser?.name ?? tour.guideId}',
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.people_outline,
                          size: 16,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tour.participantCount} Participants',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    if (guestGuideNames.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: AppColors.secondaryTealLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Guest Guide${guestGuideNames.length > 1 ? 's' : ''}: ${guestGuideNames.join(', ')}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryTealLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: tour.tourId));
                        AppToast.showSuccess(
                          'Tour Code copied to clipboard: ${tour.tourId}',
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.copy,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tour Code: ${tour.tourId}',
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text('Tour Modules', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              _buildFeatureTile(
                context,
                title: 'Itinerary & Checkpoints',
                subtitle: canManageTour
                    ? 'Manage daily schedule, meeting points & checkpoints'
                    : 'View daily schedule, meeting points & activities',
                icon: Icons.route,
                onTap: () => context.push('/tours/$tourId/itinerary'),
              ),
              _buildFeatureTile(
                context,
                title: 'Attendance & Roll Call',
                subtitle: canManageTour
                    ? 'Roll call, QR badge scanner & live analytics'
                    : 'Check-in status & attendance history',
                icon: Icons.fact_check,
                onTap: () => context.push('/tours/$tourId/attendance'),
              ),
              _buildFeatureTile(
                context,
                title: 'Crew & Participant Roster (${tour.participantCount})',
                subtitle: canManageTour
                    ? 'Participant personal details, address, age & direct dialer'
                    : 'View enrolled expedition companions',
                icon: Icons.people_alt_outlined,
                onTap: () => _showManageParticipantsSheet(
                  context,
                  ref,
                  tour,
                  allUsers,
                  isPrimaryGuide: isPrimaryGuide,
                  currentUser: currentUser,
                ),
              ),
              if (!isPrimaryGuide)
                _buildFeatureTile(
                  context,
                  title: 'My QR Crew Badge',
                  subtitle:
                      'Show your personal check-in QR code to the Tour Guide',
                  icon: Icons.qr_code_2,
                  onTap: () => context.push('/tours/$tourId/qr'),
                ),
              _buildFeatureTile(
                context,
                title: 'Group Chat',
                subtitle: 'Real-time tour messaging',
                icon: Icons.chat_bubble_outline,
                onTap: () => context.push('/tours/$tourId/chat'),
              ),
              _buildFeatureTile(
                context,
                title: 'Broadcast Announcements',
                subtitle: 'Important guide & admin updates',
                icon: Icons.campaign_outlined,
                onTap: () => context.push('/tours/$tourId/announcements'),
              ),
              _buildFeatureTile(
                context,
                title: 'Live GPS Map',
                subtitle: 'Emerald expedition radar & crew positions',
                icon: Icons.map_outlined,
                onTap: () => context.push('/tours/$tourId/map'),
              ),
              _buildFeatureTile(
                context,
                title: 'Documents & Tickets',
                subtitle: 'Shared travel files, PDFs & photos',
                icon: Icons.folder_open,
                onTap: () => context.push('/tours/$tourId/documents'),
              ),
              _buildFeatureTile(
                context,
                title: 'SOS / Emergency',
                subtitle: 'Send or resolve emergency distress alerts',
                icon: Icons.sos,
                iconColor: AppColors.sosRed,
                onTap: () => context.push('/tours/$tourId/sos'),
              ),
              if (!isPrimaryGuide &&
                  currentUser != null &&
                  tour.participantIds.contains(currentUser.userId)) ...[
                const SizedBox(height: 24),
                KompassButton(
                  label: 'Leave This Tour',
                  icon: Icons.logout,
                  isOutlined: true,
                  isDestructive: true,
                  onPressed: () => _confirmLeaveTour(
                    context,
                    ref,
                    tour,
                    currentUser.userId,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: KompassLoading()),
      error: (error, stack) => Scaffold(
        appBar: const KompassAppBar(title: 'Tour Details'),
        body: RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(tourDetailProvider(tourId));
            ref.invalidate(allUsersProvider);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(child: Text('Error: $error')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.primaryGold),
        title: Text(title, style: AppTextStyles.labelLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      AppToast.showWarning('No phone number provided.');
      return;
    }
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppToast.showError('Could not open phone dialer: $e');
    }
  }

  void _showParticipantDetailsDialog(
    BuildContext context,
    UserModel user, {
    required TourModel tour,
    required UserModel? currentUser,
  }) {
    final canView = currentUser != null &&
        (currentUser.isAdmin ||
            tour.canManageTour(currentUser.userId) ||
            currentUser.userId == user.userId);

    if (!canView) {
      AppToast.showWarning(
        'Participant personal details are private to Tour Guides and Admins.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        final hasPhone = user.phoneNumber.trim().isNotEmpty;
        final hasEmergency = user.emergencyContact.trim().isNotEmpty;
        final hasAddress = user.address.trim().isNotEmpty;
        final hasGender = user.gender.trim().isNotEmpty;
        final hasAge = user.age != null;

        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryGold,
                backgroundImage: user.profileImage.isNotEmpty
                    ? NetworkImage(user.profileImage)
                    : null,
                child: user.profileImage.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.headlineMedium,
                    ),
                    Text(
                      user.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Personal Contact Number & Dialer Redirect
                Text(
                  'PERSONAL CONTACT',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.success, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasPhone ? user.phoneNumber : 'Not provided',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasPhone)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call'),
                          onPressed: () => _makePhoneCall(user.phoneNumber),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Emergency Contact & Dialer Redirect
                Text(
                  'EMERGENCY CONTACT',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.sosRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency_outlined, color: AppColors.sosRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.emergencyContactName.isNotEmpty
                                  ? user.emergencyContactName
                                  : 'Emergency Contact',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              hasEmergency ? user.emergencyContact : 'Not provided',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: hasEmergency
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasEmergency)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sosRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          icon: const Icon(Icons.phone_in_talk, size: 16),
                          label: const Text('Call SOS'),
                          onPressed: () => _makePhoneCall(user.emergencyContact),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Address & Demographics
                Text(
                  'DETAILS & RESIDENCE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Address',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                Text(
                                  hasAddress ? user.address : 'Not specified',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.wc_outlined, size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Gender',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      hasGender ? user.gender : 'Not specified',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.cake_outlined, size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Age',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      hasAge ? '${user.age} yrs' : 'Not specified',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
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
            'Are you sure you want to permanently delete "${tour.name}"? This action cannot be undone.',
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
                  if (context.mounted) {
                    context.pop();
                  }
                } catch (e) {
                  AppToast.showError('Failed to delete tour: $e');
                }
              },
              child: const Text('Delete Tour'),
            ),
          ],
        );
      },
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
            'You will no longer have access to this tour\'s itinerary, chat, or roll calls.',
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
                  if (context.mounted) {
                    context.pop();
                  }
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

  void _showEditTourDialog(
    BuildContext context,
    WidgetRef ref,
    TourModel tour,
  ) {
    final nameCtrl = TextEditingController(text: tour.name);
    final descCtrl = TextEditingController(text: tour.description);
    String selectedStatus = tour.tourStatus.label;
    bool isPublic = tour.isPublic;
    bool requireJoinApproval = tour.requireJoinApproval;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Tour & Access Settings'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Tour Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration:
                          const InputDecoration(labelText: 'Tour Status'),
                      items: TourStatus.values
                          .map((s) => DropdownMenuItem(
                                value: s.label,
                                child: Text(s.label),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isPublic ? 'Public Tour' : 'Private Tour'),
                      subtitle: Text(
                        isPublic
                            ? 'Listed in Join Tour for anyone'
                            : 'Join only via Tour Code',
                      ),
                      value: isPublic,
                      activeColor: AppColors.primaryGold,
                      onChanged: (val) => setDialogState(() => isPublic = val),
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        requireJoinApproval
                            ? 'Require Approval for Joinees'
                            : 'Auto-Admit Joinees Using Code',
                      ),
                      subtitle: Text(
                        requireJoinApproval
                            ? 'Code joinees send a request that you must Accept or Decline'
                            : 'All joinees with the Tour Code are admitted immediately',
                      ),
                      value: requireJoinApproval,
                      activeColor: AppColors.primaryGold,
                      onChanged: (val) =>
                          setDialogState(() => requireJoinApproval = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      AppToast.showWarning('Tour name cannot be empty.');
                      return;
                    }
                    final updated = tour.copyWith(
                      name: name,
                      description: descCtrl.text.trim(),
                      status: selectedStatus,
                      isPublic: isPublic,
                      requireJoinApproval: requireJoinApproval,
                    );
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    try {
                      await ref
                          .read(tourControllerProvider.notifier)
                          .updateTour(updated);
                      AppToast.showSuccess('Tour details updated successfully!');
                    } catch (e) {
                      AppToast.showError('Failed to update tour: $e');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManageParticipantsSheet(
    BuildContext parentContext,
    WidgetRef ref,
    TourModel initialTour,
    List<UserModel> allUsers, {
    required bool isPrimaryGuide,
    UserModel? currentUser,
  }) {
    final emailController = TextEditingController();
    bool isSendingInvite = false;
    String participantSearchQuery = '';

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final liveTour =
                sheetRef.watch(tourDetailProvider(initialTour.tourId)).valueOrNull ??
                    initialTour;
            final users = sheetRef.watch(allUsersProvider).valueOrNull ?? allUsers;
            final liveCurrentUser =
                sheetRef.watch(currentUserProvider).valueOrNull ?? currentUser;

            final isAdmin = liveCurrentUser?.isAdmin == true;
            final canManage = liveCurrentUser != null &&
                (liveTour.canManageTour(liveCurrentUser.userId) || isAdmin);
            final effectiveIsPrimaryGuide = isPrimaryGuide || isAdmin;

            final enrolledUsers = users
                .where((u) => liveTour.participantIds.contains(u.userId))
                .toList();
            final invitedUsers = users
                .where((u) => liveTour.invitedUserIds.contains(u.userId))
                .toList();
            final pendingUsers = users
                .where((u) => liveTour.pendingRequestUserIds.contains(u.userId))
                .toList();

            return StatefulBuilder(
              builder: (context, setSheetState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.82,
                  maxChildSize: 0.95,
                  minChildSize: 0.5,
                  builder: (_, scrollController) {
                    return ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
                      ),
                      children: [
                        Text(
                          canManage
                              ? 'Participant & Guest Guide Management'
                              : 'Tour Crew & Participants',
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 12),

                        // ── Guide / Admin Management Section ──
                        if (canManage) ...[
                          // ── 1. Join by Code Approval Setting ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                liveTour.requireJoinApproval
                                    ? 'Code Joinees: Require My Approval'
                                    : 'Code Joinees: Admit Automatically',
                                style: AppTextStyles.labelLarge,
                              ),
                              subtitle: Text(
                                liveTour.requireJoinApproval
                                    ? 'Users entering the Tour Code send a join request for you to Accept or Decline'
                                    : 'Anyone entering the Tour Code is admitted immediately',
                                style: AppTextStyles.bodySmall,
                              ),
                              value: liveTour.requireJoinApproval,
                              activeColor: AppColors.primaryGold,
                              onChanged: (val) async {
                                await sheetRef
                                    .read(tourControllerProvider.notifier)
                                    .updateTour(
                                      liveTour.copyWith(requireJoinApproval: val),
                                    );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── 2. Invite Participant by Email Search ──
                          Text(
                            'Invite Participant by Email',
                            style: AppTextStyles.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search a registered user by their exact email address to send them a tour invitation:',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Participant Email ID',
                                    hintText: 'e.g. explorer@example.com',
                                    prefixIcon: Icon(Icons.alternate_email),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 54),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                onPressed: isSendingInvite
                                    ? null
                                    : () async {
                                        final email = emailController.text.trim();
                                        if (email.isEmpty) {
                                          AppToast.showWarning(
                                            'Please enter an email address.',
                                          );
                                          return;
                                        }
                                        setSheetState(
                                          () => isSendingInvite = true,
                                        );
                                        try {
                                          final invitedUser = await sheetRef
                                              .read(
                                                tourControllerProvider.notifier,
                                              )
                                              .inviteUserByEmail(
                                                liveTour.tourId,
                                                email,
                                              );
                                          emailController.clear();
                                          AppToast.showSuccess(
                                            'Invitation sent to ${invitedUser.name} (${invitedUser.email})!',
                                          );
                                        } catch (e) {
                                          final msg = e
                                              .toString()
                                              .replaceFirst('Exception: ', '');
                                          AppToast.showError('Failed to send invite: $msg');
                                        } finally {
                                          setSheetState(
                                            () => isSendingInvite = false,
                                          );
                                        }
                                      },
                                icon: isSendingInvite
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined, size: 18),
                                label: const Text('Send Invite'),
                              ),
                            ],
                          ),

                          // ── 3. Pending Join Requests (Accept / Decline) ──
                          if (liveTour.pendingRequestUserIds.isNotEmpty) ...[
                            const Divider(height: 28),
                            Text(
                              'Pending Join Requests (${liveTour.pendingRequestUserIds.length})',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...liveTour.pendingRequestUserIds.map((uid) {
                              final reqUser = pendingUsers
                                  .where((u) => u.userId == uid)
                                  .firstOrNull;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.person_add_alt_1,
                                  color: AppColors.warning,
                                ),
                                title: Text(reqUser?.name ?? uid),
                                subtitle: Text(
                                  reqUser?.email ?? 'Requested via Tour Code',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await sheetRef
                                              .read(
                                                tourControllerProvider.notifier,
                                              )
                                              .respondToJoinRequest(
                                                liveTour.tourId,
                                                uid,
                                                approve: false,
                                              );
                                          AppToast.showInfo(
                                            'Declined join request from ${reqUser?.name ?? uid}.',
                                          );
                                        } catch (e) {
                                          AppToast.showError('Failed to decline request: $e');
                                        }
                                      },
                                      child: const Text(
                                        'Decline',
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        minimumSize: const Size(74, 34),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await sheetRef
                                              .read(
                                                tourControllerProvider.notifier,
                                              )
                                              .respondToJoinRequest(
                                                liveTour.tourId,
                                                uid,
                                                approve: true,
                                              );
                                          AppToast.showSuccess(
                                            'Accepted ${reqUser?.name ?? uid} into the tour!',
                                          );
                                        } catch (e) {
                                          AppToast.showError('Failed to accept request: $e');
                                        }
                                      },
                                      child: const Text('Accept'),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          // ── 4. Pending Sent Invitations ──
                          if (liveTour.invitedUserIds.isNotEmpty) ...[
                            const Divider(height: 28),
                            Text(
                              'Sent Email Invitations (${liveTour.invitedUserIds.length})',
                              style: AppTextStyles.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            ...liveTour.invitedUserIds.map((uid) {
                              final invUser = invitedUsers
                                  .where((u) => u.userId == uid)
                                  .firstOrNull;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.mail_outline,
                                  color: AppColors.primaryGold,
                                ),
                                title: Text(invUser?.name ?? uid),
                                subtitle: Text(
                                  '${invUser?.email ?? ''} • Pending acceptance',
                                ),
                                trailing: TextButton(
                                  onPressed: () async {
                                    try {
                                      await sheetRef
                                          .read(tourControllerProvider.notifier)
                                          .revokeInvite(liveTour.tourId, uid);
                                      AppToast.showInfo(
                                        'Invitation revoked for ${invUser?.name ?? uid}.',
                                      );
                                    } catch (e) {
                                      AppToast.showError('Failed to revoke invitation: $e');
                                    }
                                  },
                                  child: const Text(
                                    'Revoke',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              );
                            }),
                          ],
                          const Divider(height: 28),
                        ],

                        // ── 5. Enrolled Participants & Guest Guide Promotion ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Enrolled Participants (${liveTour.participantIds.length})',
                              style: AppTextStyles.labelLarge,
                            ),
                            if (liveTour.guestGuideIds.isNotEmpty)
                              Text(
                                '${liveTour.guestGuideIds.length} Guest Guide(s)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        if (effectiveIsPrimaryGuide) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Tip: Tap the shield button next to any participant to promote or revoke them as a Guest Guide.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (val) => setSheetState(() => participantSearchQuery = val.trim().toLowerCase()),
                          decoration: InputDecoration(
                            hintText: 'Search enrolled participants...',
                            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryGold),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (liveTour.participantIds.isEmpty)
                          Text(
                            'No participants enrolled yet. Invite users by email above or share the Tour Code!',
                            style: AppTextStyles.bodySmall,
                          )
                        else ...[
                          () {
                            final matchingEnrolled = enrolledUsers.where((u) {
                              if (participantSearchQuery.isEmpty) return true;
                              return u.name.toLowerCase().contains(participantSearchQuery) ||
                                  u.email.toLowerCase().contains(participantSearchQuery);
                            }).toList();

                            if (matchingEnrolled.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  'No participants matching "$participantSearchQuery"',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                                ),
                              );
                            }

                            return Column(
                              children: matchingEnrolled.map((user) {
                                final isGuest = liveTour.isGuestGuide(user.userId);
                                final isTourLeader = user.userId == liveTour.guideId;
                                final isSelf = liveCurrentUser != null && liveCurrentUser.userId == user.userId;
                                final canViewPersonalDetails = canManage || isSelf;

                                final hasPhone = user.phoneNumber.trim().isNotEmpty;
                                final hasEmergency = user.emergencyContact.trim().isNotEmpty;
                                final hasAddress = user.address.trim().isNotEmpty;

                                // ── PRIVACY ENFORCEMENT: Non-guide/non-admin viewing another participant ──
                                if (!canViewPersonalDetails) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: AppColors.border, width: 0.8),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      leading: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isTourLeader
                                            ? AppColors.primaryGold.withValues(alpha: 0.25)
                                            : isGuest
                                                ? AppColors.primaryGold.withValues(alpha: 0.15)
                                                : AppColors.surface,
                                        backgroundImage: user.profileImage.isNotEmpty
                                            ? NetworkImage(user.profileImage)
                                            : null,
                                        child: user.profileImage.isEmpty
                                            ? Icon(
                                                isTourLeader
                                                    ? Icons.star
                                                    : isGuest
                                                        ? Icons.shield
                                                        : Icons.person_outline,
                                                size: 18,
                                                color: (isTourLeader || isGuest)
                                                    ? AppColors.primaryGold
                                                    : AppColors.textSecondary,
                                              )
                                            : null,
                                      ),
                                      title: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              user.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (isTourLeader) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGold,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Tour Guide',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ] else if (isGuest) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGold,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Guest Guide',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      subtitle: Text(
                                        isTourLeader
                                            ? 'Tour Guide'
                                            : isGuest
                                                ? 'Guest Guide'
                                                : 'Expedition Member',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      trailing: const Tooltip(
                                        message: 'Personal details are private to Tour Guides and Admins.',
                                        child: Icon(
                                          Icons.lock_outline,
                                          size: 16,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                      onTap: () {
                                        AppToast.showInfo(
                                          'Participant personal details are private to Tour Guides and Admins.',
                                        );
                                      },
                                    ),
                                  );
                                }

                                // ── AUTHORIZED (Admin, Guide, or Self): Full Expandable Card with Direct Dialer ──
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: AppColors.border, width: 0.8),
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isTourLeader
                                          ? AppColors.primaryGold.withValues(alpha: 0.25)
                                          : isGuest
                                              ? AppColors.primaryGold.withValues(alpha: 0.2)
                                              : AppColors.success.withValues(alpha: 0.15),
                                      backgroundImage: user.profileImage.isNotEmpty
                                          ? NetworkImage(user.profileImage)
                                          : null,
                                      child: user.profileImage.isEmpty
                                          ? Icon(
                                              isTourLeader
                                                  ? Icons.star
                                                  : isGuest
                                                      ? Icons.shield
                                                      : Icons.person_outline,
                                              size: 18,
                                              color: (isTourLeader || isGuest)
                                                  ? AppColors.primaryGold
                                                  : AppColors.success,
                                            )
                                          : null,
                                    ),
                                    title: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (isSelf) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGold.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.primaryGold, width: 0.8),
                                            ),
                                            child: const Text(
                                              'You',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryGold,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (isTourLeader) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGold,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Tour Guide',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ] else if (isGuest) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGold,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Guest Guide',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.email, style: AppTextStyles.bodySmall),
                                        if (hasPhone)
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 12, color: AppColors.success),
                                              const SizedBox(width: 4),
                                              Text(
                                                user.phoneNumber,
                                                style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (hasPhone)
                                          IconButton(
                                            icon: const Icon(Icons.phone, color: AppColors.success, size: 20),
                                            tooltip: 'Call ${user.name}',
                                            onPressed: () => _makePhoneCall(user.phoneNumber),
                                          ),
                                        if (hasEmergency)
                                          IconButton(
                                            icon: const Icon(Icons.phone_in_talk, color: AppColors.sosRed, size: 20),
                                            tooltip: 'Call Emergency Contact',
                                            onPressed: () => _makePhoneCall(user.emergencyContact),
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.info_outline, color: AppColors.primaryGold, size: 20),
                                          tooltip: 'View Personal & Safety Details',
                                          onPressed: () => _showParticipantDetailsDialog(
                                            context,
                                            user,
                                            tour: liveTour,
                                            currentUser: liveCurrentUser,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      const Divider(height: 12),
                                      // 1. Personal Phone & Call row
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_outlined, size: 16, color: AppColors.primaryGold),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Contact Number', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                                Text(
                                                  hasPhone ? user.phoneNumber : 'Not provided',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    fontWeight: hasPhone ? FontWeight.w600 : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (hasPhone)
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.success,
                                                foregroundColor: Colors.white,
                                                minimumSize: const Size(0, 30),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              ),
                                              icon: const Icon(Icons.call, size: 13),
                                              label: const Text('Call', style: TextStyle(fontSize: 11)),
                                              onPressed: () => _makePhoneCall(user.phoneNumber),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // 2. Address row
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryGold),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Address', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                                Text(
                                                  hasAddress ? user.address : 'Not provided',
                                                  style: AppTextStyles.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // 3. Gender & Age row
                                      Row(
                                        children: [
                                          const Icon(Icons.badge_outlined, size: 16, color: AppColors.primaryGold),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Gender & Age', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                                Text(
                                                  'Gender: ${user.gender.isNotEmpty ? user.gender : "Not provided"} • Age: ${user.age != null ? "${user.age} yrs" : "Not provided"}',
                                                  style: AppTextStyles.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // 4. Emergency Contact row
                                      Row(
                                        children: [
                                          const Icon(Icons.emergency_outlined, size: 16, color: AppColors.sosRed),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Emergency: ${user.emergencyContactName.isNotEmpty ? user.emergencyContactName : "Contact"}',
                                                  style: const TextStyle(fontSize: 10, color: AppColors.sosRed, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  hasEmergency ? user.emergencyContact : 'Not provided',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    fontWeight: hasEmergency ? FontWeight.w600 : FontWeight.normal,
                                                    color: hasEmergency ? AppColors.textPrimary : AppColors.textHint,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (hasEmergency)
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.sosRed,
                                                foregroundColor: Colors.white,
                                                minimumSize: const Size(0, 30),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              ),
                                              icon: const Icon(Icons.phone_in_talk, size: 13),
                                              label: const Text('Call SOS', style: TextStyle(fontSize: 11)),
                                              onPressed: () => _makePhoneCall(user.emergencyContact),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // 5. Guide Controls (only for primary guide or admin, cannot promote/remove themselves)
                                      if (effectiveIsPrimaryGuide && user.userId != liveCurrentUser.userId)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: isGuest
                                                    ? AppColors.warning
                                                    : AppColors.primaryGold,
                                                side: BorderSide(
                                                  color: isGuest
                                                      ? AppColors.warning
                                                      : AppColors.primaryGold,
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                minimumSize: const Size(0, 28),
                                              ),
                                              icon: Icon(
                                                isGuest
                                                    ? Icons.remove_moderator_outlined
                                                    : Icons.add_moderator_outlined,
                                                size: 13,
                                              ),
                                              label: Text(
                                                isGuest
                                                    ? 'Revoke Guide'
                                                    : 'Make Guest Guide',
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await sheetRef
                                                      .read(tourControllerProvider.notifier)
                                                      .toggleGuestGuide(
                                                        liveTour.tourId,
                                                        user.userId,
                                                        isGuestGuide: !isGuest,
                                                      );
                                                  if (!isGuest) {
                                                    AppToast.showSuccess(
                                                      '${user.name} promoted to Guest Guide!',
                                                    );
                                                  } else {
                                                    AppToast.showInfo(
                                                      'Guest Guide status revoked for ${user.name}.',
                                                    );
                                                  }
                                                } catch (e) {
                                                  AppToast.showError(
                                                    'Failed to update Guest Guide status: $e',
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              style: TextButton.styleFrom(
                                                foregroundColor: AppColors.error,
                                                minimumSize: const Size(0, 28),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                              ),
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                size: 13,
                                              ),
                                              label: const Text('Remove', style: TextStyle(fontSize: 10)),
                                              onPressed: () async {
                                                try {
                                                  await sheetRef
                                                      .read(tourControllerProvider.notifier)
                                                      .removeParticipant(liveTour.tourId, user.userId);
                                                  AppToast.showInfo(
                                                    'Removed ${user.name} from the tour.',
                                                  );
                                                } catch (e) {
                                                  AppToast.showError('Failed to remove participant: $e');
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }(),
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
