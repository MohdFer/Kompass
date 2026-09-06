import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/providers/auth_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.name ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $userName!', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: KompassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Total Users', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 8),
                          Text('120', style: AppTextStyles.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KompassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Active Tours', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 8),
                          Text('5', style: AppTextStyles.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            KompassButton(label: 'Manage Tours',
              onPressed: () => context.goNamed(RouteNames.tours),
            ),
          ],
        ),
      ),
    );
  }
}
