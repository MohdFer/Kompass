import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/providers/auth_providers.dart';

class ParticipantDashboardScreen extends ConsumerWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: KompassAppBar(
        title: 'Explorer\'s Journal',
        showCompass: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.goNamed(RouteNames.login);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Your Adventures', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Every journey begins with a single step.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          // TODO: List participant's tours
          Center(
            child: Column(
              children: [
                const Icon(Icons.sailing, size: 64, color: AppColors.sandDark),
                const SizedBox(height: 16),
                Text(
                  'No active voyages yet',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
