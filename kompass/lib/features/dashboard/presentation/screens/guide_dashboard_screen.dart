import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/providers/auth_providers.dart';

class GuideDashboardScreen extends ConsumerWidget {
  const GuideDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.name ?? 'Guide';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Dashboard'),
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
            const SizedBox(height: 32),
            KompassButton(label: 'Create New Tour',
              onPressed: () => context.goNamed(RouteNames.createTour),
            ),
            const SizedBox(height: 16),
            KompassButton(label: 'View Assigned Tours',
              onPressed: () => context.goNamed(RouteNames.tours),
            ),
          ],
        ),
      ),
    );
  }
}
