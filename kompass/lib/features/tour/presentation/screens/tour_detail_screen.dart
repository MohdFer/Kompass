import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../providers/tour_providers.dart';

class TourDetailScreen extends ConsumerWidget {
  final String tourId;
  const TourDetailScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourDetailProvider(tourId));

    return Scaffold(
      appBar: const KompassAppBar(title: 'Tour Details'),
      body: tourAsync.when(
        data: (tour) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(tour.name, style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(tour.description, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              if (tour.startDate != null && tour.endDate != null)
                Text('From: ${tour.startDate.toString().split(' ')[0]} To: ${tour.endDate.toString().split(' ')[0]}'),
              const Divider(height: 32),
              _buildFeatureTile(
                context, 
                title: 'Itinerary', 
                icon: Icons.map, 
                onTap: () => context.push('/tours/$tourId/itinerary')
              ),
              _buildFeatureTile(
                context, 
                title: 'Chat', 
                icon: Icons.chat, 
                onTap: () => context.push('/tours/$tourId/chat')
              ),
              _buildFeatureTile(
                context, 
                title: 'Attendance', 
                icon: Icons.check_circle, 
                onTap: () => context.push('/tours/$tourId/attendance')
              ),
              _buildFeatureTile(
                context, 
                title: 'Map', 
                icon: Icons.location_on, 
                onTap: () => context.push('/tours/$tourId/map')
              ),
              _buildFeatureTile(
                context, 
                title: 'Announcements', 
                icon: Icons.announcement, 
                onTap: () => context.push('/tours/$tourId/announcements')
              ),
              _buildFeatureTile(
                context, 
                title: 'Documents', 
                icon: Icons.folder, 
                onTap: () => context.push('/tours/$tourId/documents')
              ),
              _buildFeatureTile(
                context, 
                title: 'SOS / Emergency', 
                icon: Icons.warning, 
                onTap: () => context.push('/tours/$tourId/emergency'),
                iconColor: Colors.red,
              ),
            ],
          );
        },
        loading: () => const KompassLoading(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
