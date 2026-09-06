import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/providers/auth_providers.dart';

class GuideDashboardScreen extends ConsumerWidget {
  const GuideDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: KompassAppBar(
        title: 'Navigator\'s Deck',
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
          Text('Your Voyages', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Lead your crew through unforgettable adventures.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          KompassCard(
            onTap: () => context.pushNamed(RouteNames.tours),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.map, color: AppColors.primaryGold, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tours', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 4),
                      Text('View and manage assigned tours', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
