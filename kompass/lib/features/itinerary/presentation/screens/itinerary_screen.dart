import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../data/models/itinerary_model.dart';
import '../../providers/itinerary_providers.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tourId;
  const ItineraryScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerariesAsync = ref.watch(tourItinerariesProvider(tourId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final tour = ref.watch(tourDetailProvider(tourId)).valueOrNull;

    final canManageItinerary = currentUser != null &&
        tour != null &&
        tour.canManageTour(currentUser.userId);

    Future<void> onRefresh() async {
      ref.invalidate(tourItinerariesProvider(tourId));
      ref.invalidate(tourDetailProvider(tourId));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    return Scaffold(
      appBar: const KompassAppBar(title: 'Itinerary & Checkpoints'),
      body: itinerariesAsync.when(
        data: (itineraries) {
          return RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: onRefresh,
            child: itineraries.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 160),
                      KompassEmptyState(
                        message: canManageItinerary
                            ? 'No itinerary days planned yet. Tap + to add a day!'
                            : 'No itinerary days have been published by the Tour Guide yet.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: itineraries.length,
                    itemBuilder: (context, index) {
                      final item = itineraries[index];
                      return _buildItineraryCard(
                        context,
                        ref,
                        item,
                        canManage: canManageItinerary,
                      );
                    },
                  ),
          );
        },
        loading: () => const KompassLoading(),
        error: (error, stack) => RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(child: Text('Error: $error')),
            ],
          ),
        ),
      ),
      floatingActionButton: canManageItinerary
          ? FloatingActionButton.extended(
              onPressed: () => _showAddItineraryDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Day'),
            )
          : null,
    );
  }

  Widget _buildItineraryCard(
    BuildContext context,
    WidgetRef ref,
    ItineraryModel item, {
    required bool canManage,
  }) {
    final totalActivities = item.activities.length;
    final completedActivities =
        item.activities.where((a) => a.isCompleted).length;
    final progressFraction =
        totalActivities > 0 ? completedActivities / totalActivities : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.title, style: AppTextStyles.headlineLarge),
                ),
                if (canManage)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Delete Day',
                    onPressed: () async {
                      try {
                        await ref
                            .read(itineraryControllerProvider.notifier)
                            .deleteItinerary(tourId, item.itineraryId);
                        AppToast.showSuccess('Itinerary day "${item.title}" deleted.');
                      } catch (e) {
                        AppToast.showError('Failed to delete itinerary day: $e');
                      }
                    },
                  ),
              ],
            ),
            Text(
              'Date: ${item.date.toString().split(' ')[0]}',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryGold),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.description, style: AppTextStyles.bodyMedium),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activities & Checkpoints', style: AppTextStyles.labelLarge),
                if (canManage)
                  TextButton.icon(
                    onPressed: () => _showAddActivityDialog(context, ref, item),
                    icon: const Icon(Icons.add_location_alt, size: 18),
                    label: const Text('Add Checkpoint'),
                  ),
              ],
            ),
            if (totalActivities > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedActivities == totalActivities
                              ? AppColors.success
                              : AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$completedActivities/$totalActivities Completed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: completedActivities == totalActivities
                          ? AppColors.success
                          : AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (item.activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No checkpoints or activities added yet.',
                  style: AppTextStyles.bodySmall,
                ),
              )
            else
              ...item.activities.asMap().entries.map((entry) {
                final idx = entry.key;
                final activity = entry.value;
                return _buildCheckpointItem(
                  context: context,
                  ref: ref,
                  item: item,
                  activity: activity,
                  idx: idx,
                  canManage: canManage,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointItem({
    required BuildContext context,
    required WidgetRef ref,
    required ItineraryModel item,
    required ActivityItem activity,
    required int idx,
    required bool canManage,
  }) {
    Future<void> toggleCompletion() async {
      if (!canManage) {
        AppToast.showInfo('Checkpoint status is managed live by your Tour Guide.');
        return;
      }
      final isNowCompleted = !activity.isCompleted;
      final updatedList = List<ActivityItem>.from(item.activities);
      updatedList[idx] = activity.copyWith(isCompleted: isNowCompleted);
      try {
        await ref.read(itineraryControllerProvider.notifier).updateItinerary(
              tourId,
              item.copyWith(activities: updatedList),
            );
        if (isNowCompleted) {
          AppToast.showSuccess('Checkpoint "${activity.name}" completed!');
        } else {
          AppToast.showInfo('Checkpoint "${activity.name}" marked as pending.');
        }
      } catch (e) {
        AppToast.showError('Failed to update checkpoint: $e');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: activity.isCompleted
            ? AppColors.surfaceVariant.withValues(alpha: 0.5)
            : AppColors.surfaceVariant.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.isCompleted
              ? AppColors.primaryGold.withValues(alpha: 0.35)
              : AppColors.border,
          width: activity.isCompleted ? 1.4 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: toggleCompletion,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox / Checklist Box
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: GestureDetector(
                  onTap: toggleCompletion,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: activity.isCompleted
                          ? AppColors.primaryGold
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: activity.isCompleted
                            ? AppColors.primaryGold
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                    ),
                    child: activity.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.background,
                          )
                        : null,
                  ),
                ),
              ),

              // Checkpoint Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.name,
                            style: AppTextStyles.labelLarge.copyWith(
                              decoration: activity.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.primaryGold,
                              decorationThickness: 2,
                              color: activity.isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (activity.isCompleted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 11,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'COMPLETED',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.startTime} - ${activity.endTime}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                          ),
                        ),
                        if (activity.locationName.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.place_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              activity.locationName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (activity.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button for tour guides
              if (canManage)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Remove checkpoint',
                  onPressed: () async {
                    try {
                      final updatedList = List<ActivityItem>.from(item.activities)
                        ..removeAt(idx);
                      await ref
                          .read(itineraryControllerProvider.notifier)
                          .updateItinerary(
                            tourId,
                            item.copyWith(activities: updatedList),
                          );
                      AppToast.showInfo('Checkpoint "${activity.name}" removed.');
                    } catch (e) {
                      AppToast.showError('Failed to remove checkpoint: $e');
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItineraryDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Itinerary Day'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Day Title (e.g., Day 1: Old City)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description / Notes',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date: ${selectedDate.toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
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
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      AppToast.showWarning('Please enter a title for this itinerary day.');
                      return;
                    }
                    final newItinerary = ItineraryModel(
                      itineraryId: '',
                      tourId: tourId,
                      title: title,
                      description: descController.text.trim(),
                      date: selectedDate,
                    );
                    Navigator.pop(dialogContext);
                    try {
                      await ref
                          .read(itineraryControllerProvider.notifier)
                          .createItinerary(tourId, newItinerary);
                      AppToast.showSuccess('Itinerary day "$title" added successfully!');
                    } catch (e) {
                      AppToast.showError('Failed to add itinerary day: $e');
                    }
                  },
                  child: const Text('Add Day'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddActivityDialog(
    BuildContext context,
    WidgetRef ref,
    ItineraryModel itinerary,
  ) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '09:00 AM');
    final endCtrl = TextEditingController(text: '11:00 AM');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Activity / Checkpoint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Activity / Checkpoint Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Point / Destination',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl,
                        decoration: const InputDecoration(labelText: 'Start Time'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: endCtrl,
                        decoration: const InputDecoration(labelText: 'End Time'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Details / Instructions',
                  ),
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
                  AppToast.showWarning('Please enter a checkpoint name.');
                  return;
                }
                final newActivity = ActivityItem(
                  name: name,
                  locationName: locationCtrl.text.trim(),
                  startTime: startCtrl.text.trim(),
                  endTime: endCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                final updatedActivities = [
                  ...itinerary.activities,
                  newActivity,
                ];
                Navigator.pop(dialogContext);
                try {
                  await ref.read(itineraryControllerProvider.notifier).updateItinerary(
                        tourId,
                        itinerary.copyWith(activities: updatedActivities),
                      );
                  AppToast.showSuccess('Checkpoint "$name" saved successfully!');
                } catch (e) {
                  AppToast.showError('Failed to save checkpoint: $e');
                }
              },
              child: const Text('Save Checkpoint'),
            ),
          ],
        );
      },
    );
  }
}
