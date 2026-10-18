import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../services/notifications/fcm_direct_dispatcher.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../providers/messaging_providers.dart';
import '../../data/models/announcement_model.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({required this.tourId, super.key});
  final String tourId;

  void _showAddAnnouncementDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Broadcast Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final msg = messageController.text.trim();
              if (title.isEmpty || msg.isEmpty) {
                AppToast.showWarning('Please enter both a title and message.');
                return;
              }

              final user = ref.read(currentUserProvider).valueOrNull;
              final authUser = ref.read(authStateChangesProvider).valueOrNull;
              final tour = ref.read(tourDetailProvider(tourId)).valueOrNull;
              if (authUser == null) {
                AppToast.showError('User session expired. Please sign in again.');
                return;
              }

              final senderName = user?.name ?? 'Tour Guide';
              final announcement = AnnouncementModel(
                announcementId: '',
                tourId: tourId,
                title: title,
                message: msg,
                createdBy: authUser.uid,
                createdByName: senderName,
              );

              Navigator.pop(dialogContext);
              try {
                final announcementId = await ref
                    .read(announcementRepositoryProvider)
                    .createAnnouncement(tourId, announcement);

                // Dispatch direct background push notification to all participants via FCM
                unawaited(
                  FcmDirectDispatcher.instance.sendAnnouncement(
                    tourId: tourId,
                    tourName: tour?.name ?? 'Tour',
                    title: title,
                    messageText: msg,
                    senderId: authUser.uid,
                    announcementId: announcementId,
                  ).catchError((err) {
                    debugPrint('FCM direct send announcement error: $err');
                  }),
                );

                // Dispatch local device notification confirmation as well
                await NotificationService.instance.showNotification(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: '📢 BROADCAST: $title',
                  body: '$msg\n— $senderName (${tour?.name ?? 'Tour'})',
                  payload: 'announcement:$tourId',
                );

                AppToast.showSuccess('Broadcast announcement sent to all participants!');
              } catch (e) {
                AppToast.showError('Failed to post announcement: $e');
              }
            },
            child: const Text('Broadcast'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(tourAnnouncementsProvider(tourId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final tour = ref.watch(tourDetailProvider(tourId)).valueOrNull;
    final canBroadcast = currentUser != null &&
        (currentUser.userRole == UserRole.admin ||
            (tour != null && tour.canManageTour(currentUser.userId)));

    Future<void> onRefresh() async {
      ref.invalidate(tourAnnouncementsProvider(tourId));
      ref.invalidate(tourDetailProvider(tourId));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    return Scaffold(
      appBar: const KompassAppBar(title: 'Captain\'s Orders'),
      floatingActionButton: canBroadcast
          ? FloatingActionButton.extended(
              onPressed: () => _showAddAnnouncementDialog(context, ref),
              icon: const Icon(Icons.campaign),
              label: const Text('Broadcast'),
            )
          : null,
      body: announcementsAsync.when(
        data: (announcements) {
          return RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: onRefresh,
            child: announcements.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 160),
                      KompassEmptyState(
                        title: 'No announcements',
                        message: 'Pull down to refresh or check back later for updates.',
                        icon: Icons.campaign_outlined,
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: AppTextStyles.headlineLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                announcement.message,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'By ${announcement.createdByName}',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  if (announcement.timestamp != null)
                                    Text(
                                      DateFormat.yMMMd()
                                          .add_jm()
                                          .format(announcement.timestamp!),
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
        loading: () => const Center(child: KompassLoading()),
        error: (e, st) => RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(child: Text('Error: $e')),
            ],
          ),
        ),
      ),
    );
  }
}
