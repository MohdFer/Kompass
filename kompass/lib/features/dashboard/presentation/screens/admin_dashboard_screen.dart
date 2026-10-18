import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.name ?? 'Admin';
    final allUsersAsync = ref.watch(allUsersProvider);
    final toursAsync = ref.watch(toursProvider);

    final totalUsersCount = allUsersAsync.valueOrNull?.length ?? 0;
    final totalTours = toursAsync.valueOrNull ?? [];
    final activeToursCount =
        totalTours.where((t) => t.status.toLowerCase() == 'active').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              AppToast.showInfo('Signed out successfully.');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Welcome, $userName!', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KompassCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const Icon(Icons.people, color: AppColors.primaryGold, size: 28),
                      const SizedBox(height: 8),
                      Text('Total Users', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        allUsersAsync.isLoading ? '...' : '$totalUsersCount',
                        style: AppTextStyles.displayMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KompassCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const Icon(Icons.explore, color: AppColors.secondaryTealLight, size: 28),
                      const SizedBox(height: 8),
                      Text('Active / Total Tours', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        toursAsync.isLoading
                            ? '...'
                            : '$activeToursCount / ${totalTours.length}',
                        style: AppTextStyles.displayMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          KompassButton(
            label: 'Create New Tour',
            icon: Icons.add,
            onPressed: () => context.push('/tours/create'),
          ),
          const SizedBox(height: 12),
          KompassButton(
            label: 'Manage All Tours',
            icon: Icons.list_alt,
            isOutlined: true,
            onPressed: () => context.push('/tours'),
          ),
          const SizedBox(height: 24),
          Text('Recent Tours', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          if (totalTours.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No tours created yet.')),
            )
          else
            ...totalTours.take(5).map(
                  (tour) => KompassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    onTap: () => context.push('/tours/${tour.tourId}'),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(tour.name, style: AppTextStyles.headlineMedium),
                      subtitle: Text(
                        'Status: ${tour.status} • Participants: ${tour.participantCount}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
