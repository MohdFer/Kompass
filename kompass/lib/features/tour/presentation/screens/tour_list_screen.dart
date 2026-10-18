import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../providers/tour_providers.dart';

class TourListScreen extends ConsumerWidget {
  const TourListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toursAsync = ref.watch(toursProvider);

    return Scaffold(
      appBar: const KompassAppBar(title: 'Tours'),
      body: toursAsync.when(
        data: (tours) {
          if (tours.isEmpty) {
            return const KompassEmptyState(message: 'No tours found.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return KompassCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tour.name),
                  subtitle: Text(
                    '${tour.description}\nStatus: ${tour.status} • Participants: ${tour.participantCount}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                ),
                onTap: () => context.push('/tours/${tour.tourId}'),
              );
            },
          );
        },
        loading: () => const KompassLoading(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tours/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
