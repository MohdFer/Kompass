import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/providers/auth_providers.dart';

class QRGeneratorScreen extends ConsumerWidget {
  const QRGeneratorScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    Future<void> onRefresh() async {
      ref.invalidate(currentUserProvider);
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    return Scaffold(
      appBar: const KompassAppBar(title: 'Your Crew Badge'),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not logged in'));
          }

          // Generate QR data format: "userId|tourId"
          final qrData = '${user.userId}|$tourId';

          return RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
              children: [
                Center(
                  child: Text(
                    'Show this to your Guide',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primaryGoldDark),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    user.name,
                    style: AppTextStyles.headlineLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Ready for Roll Call',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (e, st) => RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(child: Text('Error: $e')),
            ],
          ),
        ),
      ),
    );
  }
}
