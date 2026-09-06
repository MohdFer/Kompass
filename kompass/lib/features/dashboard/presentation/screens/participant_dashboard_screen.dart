import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../auth/providers/auth_providers.dart';

class ParticipantDashboardScreen extends ConsumerWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.name ?? 'Participant';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
            Center(
              child: Text(
                'You are not currently in an active tour.',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            KompassButton(label: 'Join Tour',
              onPressed: () {
                // Placeholder
              },
            ),
          ],
        ),
      ),
    );
  }
}
