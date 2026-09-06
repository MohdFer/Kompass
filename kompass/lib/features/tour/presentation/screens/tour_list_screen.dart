import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../routing/route_names.dart';
import '../../providers/tour_providers.dart';

class TourListScreen extends ConsumerWidget {
  const TourListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toursAsync = ref.watch(allToursProvider);

    return Scaffold(
      appBar: const KompassAppBar(title: 'All Voyages'),
      body: toursAsync.when(
        loading: () => const KompassLoading(message: 'Charting courses...'),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (tours) {
          if (tours.isEmpty) {
            return KompassEmptyState(
              message: 'No voyages charted yet.\nCreate your first adventure!',
              icon: Icons.map,
              actionLabel: 'Chart a New Course',
              onAction: () => context.pushNamed(RouteNames.createTour),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return ListTile(
                title: Text(tour.name),
                subtitle: Text(tour.description),
                trailing: Chip(label: Text(tour.status)),
                onTap: () => context.pushNamed(
                  RouteNames.tourDetail,
                  pathParameters: {'tourId': tour.tourId},
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.createTour),
        child: const Icon(Icons.add),
      ),
    );
  }
}
