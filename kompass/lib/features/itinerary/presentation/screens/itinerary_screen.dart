import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../providers/itinerary_providers.dart';
import '../../data/models/itinerary_model.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tourId;
  const ItineraryScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerariesAsync = ref.watch(tourItinerariesProvider(tourId));

    return Scaffold(
      appBar: const KompassAppBar(title: 'Itinerary'),
      body: itinerariesAsync.when(
        data: (itineraries) {
          if (itineraries.isEmpty) {
            return const KompassEmptyState(message: 'No itinerary planned yet.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itineraries.length,
            itemBuilder: (context, index) {
              final item = itineraries[index];
              return _buildItineraryCard(context, item);
            },
          );
        },
        loading: () => const KompassLoading(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItineraryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItineraryCard(BuildContext context, ItineraryModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: AppTextStyles.headlineLarge),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.description, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 16),
            Text('Date: ${item.date.toString().split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            if (item.activities.isEmpty)
              const Text('No activities added.')
            else
              ...item.activities.map((activity) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(activity.name),
                    subtitle: Text('${activity.startTime} - ${activity.endTime} \n${activity.locationName}'),
                    isThreeLine: true,
                  )),
          ],
        ),
      ),
    );
  }

  void _showAddItineraryDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Itinerary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
                child: const Text('Select Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedDate != null) {
                  final newItinerary = ItineraryModel(
                    itineraryId: '',
                    tourId: tourId,
                    title: titleController.text,
                    date: selectedDate!,
                  );
                  ref.read(itineraryControllerProvider.notifier).createItinerary(tourId, newItinerary);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
