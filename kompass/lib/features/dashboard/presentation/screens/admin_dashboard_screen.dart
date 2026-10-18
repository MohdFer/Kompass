import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_lifecycle_helper.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../location/providers/location_providers.dart';
import '../../../../services/permissions/app_permission_service.dart';
import '../../../tour/providers/tour_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.name ?? 'Admin';
    final allUsersAsync = ref.watch(allUsersProvider);
    final toursAsync = ref.watch(toursProvider);
    final gpsStatus = ref.watch(gpsStatusProvider);

    final totalUsersCount = allUsersAsync.valueOrNull?.length ?? 0;
    final totalTours = toursAsync.valueOrNull ?? [];
    final activeToursCount =
        totalTours.where((t) => t.status.toLowerCase() == 'active').length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        AppPermissionService.instance.checkAndPromptBatteryOptimization(context: context);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        AppLifecycleHelper.sendToBackground();
      },
      child: Scaffold(
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
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(currentUserProvider);
          ref.invalidate(allUsersProvider);
          ref.invalidate(toursProvider);
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            if (gpsStatus.isGpsDisabledWhenRequired) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: AppColors.primaryGold, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GPS Location is Turned Off',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryGold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tour tracking is active for your guided tour. Please turn on Location in Settings so participants can track your position.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Geolocator.openLocationSettings(),
                      child: const Text('Turn On', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
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
      ),
    ),
    );
  }
}
