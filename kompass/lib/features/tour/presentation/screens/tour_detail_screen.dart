import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../routing/route_names.dart';
import '../../providers/tour_providers.dart';

class TourDetailScreen extends ConsumerWidget {
  const TourDetailScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourDetailProvider(tourId));

    return Scaffold(
      appBar: const KompassAppBar(title: 'Voyage Details'),
      body: tourAsync.when(
        loading: () => const KompassLoading(message: 'Loading voyage...'),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(tour.name, style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(tour.description, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),
              Text('Quick Actions', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionChip(
                    icon: Icons.calendar_today,
                    label: 'Itinerary',
                    onTap: () => context.pushNamed(RouteNames.itinerary, pathParameters: {'tourId': tourId}),
                  ),
                  _ActionChip(
                    icon: Icons.qr_code_scanner,
                    label: 'Attendance',
                    onTap: () => context.pushNamed(RouteNames.attendance, pathParameters: {'tourId': tourId}),
                  ),
                  _ActionChip(
                    icon: Icons.chat,
                    label: 'Chat',
                    onTap: () => context.pushNamed(RouteNames.chat, pathParameters: {'tourId': tourId}),
                  ),
                  _ActionChip(
                    icon: Icons.campaign,
                    label: 'Announcements',
                    onTap: () => context.pushNamed(RouteNames.announcements, pathParameters: {'tourId': tourId}),
                  ),
                  _ActionChip(
                    icon: Icons.map,
                    label: 'Map',
                    onTap: () => context.pushNamed(RouteNames.map, pathParameters: {'tourId': tourId}),
                  ),
                  _ActionChip(
                    icon: Icons.folder,
                    label: 'Documents',
                    onTap: () => context.pushNamed(RouteNames.documents, pathParameters: {'tourId': tourId}),
                  ),
                  _ActionChip(
                    icon: Icons.sos,
                    label: 'SOS Alerts',
                    onTap: () => context.pushNamed(RouteNames.sos, pathParameters: {'tourId': tourId}),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KompassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGold),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}
