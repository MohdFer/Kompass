import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../data/models/itinerary_model.dart';
import '../../providers/itinerary_providers.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tourId;
  const ItineraryScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerariesAsync = ref.watch(tourItinerariesProvider(tourId));

    return Scaffold(
      appBar: const KompassAppBar(title: 'Itinerary & Checkpoints'),
      body: itinerariesAsync.when(
        data: (itineraries) {
          if (itineraries.isEmpty) {
            return const KompassEmptyState(
              message: 'No itinerary days planned yet. Tap + to add a day!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itineraries.length,
            itemBuilder: (context, index) {
              final item = itineraries[index];
              return _buildItineraryCard(context, ref, item);
            },
          );
        },
        loading: () => const KompassLoading(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItineraryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Day'),
      ),
    );
  }

  Widget _buildItineraryCard(
    BuildContext context,
    WidgetRef ref,
    ItineraryModel item,
  ) {
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
                TextButton.icon(
                  onPressed: () => _showAddActivityDialog(context, ref, item),
                  icon: const Icon(Icons.add_location_alt, size: 18),
                  label: const Text('Add Checkpoint'),
                ),
              ],
            ),
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
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(Icons.place, size: 18, color: AppColors.primaryGold),
                  ),
                  title: Text(activity.name, style: AppTextStyles.labelLarge),
                  subtitle: Text(
                    '${activity.startTime} - ${activity.endTime}'
                    '${activity.locationName.isNotEmpty ? ' • Meeting Point: ${activity.locationName}' : ''}'
                    '${activity.description.isNotEmpty ? '\n${activity.description}' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
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
                );
              }),
          ],
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
