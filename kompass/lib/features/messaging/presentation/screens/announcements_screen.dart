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
import '../../../auth/providers/auth_providers.dart';
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
        title: const Text('New Announcement'),
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

              final user = ref.read(currentUserProvider).value;
              final authUser = ref.read(authStateChangesProvider).value;
              if (authUser == null) {
                AppToast.showError('User session expired. Please sign in again.');
                return;
              }

              final announcement = AnnouncementModel(
                announcementId: '',
                tourId: tourId,
                title: title,
                message: msg,
                createdBy: authUser.uid,
                createdByName: user?.name ?? 'Guide',
              );

              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(announcementRepositoryProvider)
                    .createAnnouncement(tourId, announcement);
                AppToast.showSuccess('Announcement posted successfully!');
              } catch (e) {
                AppToast.showError('Failed to post announcement: $e');
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(tourAnnouncementsProvider(tourId));
    final currentUser = ref.watch(currentUserProvider).value;
    final isGuide = currentUser?.userRole == UserRole.guide || currentUser?.userRole == UserRole.admin;

    return Scaffold(
      appBar: const KompassAppBar(title: 'Captain\'s Orders'),
      floatingActionButton: isGuide
          ? FloatingActionButton(
              onPressed: () => _showAddAnnouncementDialog(context, ref),
              child: const Icon(Icons.campaign),
            )
          : null,
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return const KompassEmptyState(
              title: 'No announcements',
              message: 'Check back later for updates.',
              icon: Icons.campaign_outlined,
            );
          }
          return ListView.builder(
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
                      Text(announcement.title, style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 8),
                      Text(announcement.message, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('By ${announcement.createdByName}', style: AppTextStyles.labelMedium),
                          if (announcement.timestamp != null)
                            Text(
                              DateFormat.yMMMd().add_jm().format(announcement.timestamp!),
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: KompassLoading()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
