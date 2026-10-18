import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../services/permissions/app_permission_service.dart';
import '../../../../services/storage/hive_service.dart';
import '../../providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _avatarUrlController;
  bool _locationConsent = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _locationConsent = HiveService.instance.isLocationSharingEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: const KompassAppBar(title: 'User Profile'),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }
          if (!_initialized) {
            _nameController.text = user.name;
            _avatarUrlController.text = user.profileImage;
            _initialized = true;
          }

          return RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              setState(() => _initialized = false);
              ref.invalidate(currentUserProvider);
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryGold,
                    backgroundImage: user.profileImage.isNotEmpty
                        ? NetworkImage(user.profileImage)
                        : null,
                    child: user.profileImage.isEmpty
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(user.email, style: AppTextStyles.bodyMedium),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Chip(
                    label: Text('Guide & Explorer'),
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                KompassCard(
                  margin: EdgeInsets.zero,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Profile', style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _avatarUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Profile Image URL (optional)',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('GPS Location Sharing Consent'),
                          subtitle: const Text(
                            'Allow tour guides to view your live GPS position during active tours',
                          ),
                          value: _locationConsent,
                          activeColor: AppColors.primaryGold,
                          onChanged: (val) async {
                            await HiveService.instance.setLocationSharing(enabled: val);
                            setState(() => _locationConsent = val);
                            AppToast.showInfo(
                              val
                                  ? 'GPS location sharing enabled.'
                                  : 'GPS location sharing disabled.',
                            );
                          },
                        ),
                        const Divider(color: AppColors.border, height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.battery_charging_full_rounded,
                            color: AppColors.primaryGold,
                          ),
                          title: const Text('Unrestricted Battery Usage'),
                          subtitle: const Text(
                            'Ensure instant delivery of background chat, broadcast, and emergency SOS alerts.',
                          ),
                          trailing: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGold,
                              side: const BorderSide(color: AppColors.primaryGold),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () async {
                              await AppPermissionService.instance.requestUnrestrictedBatteryOptimization();
                            },
                            child: const Text('Configure'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        KompassButton(
                          label: 'Save Changes',
                          icon: Icons.save,
                          isLoading: authState.isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final updated = user.copyWith(
                                name: _nameController.text.trim(),
                                profileImage: _avatarUrlController.text.trim(),
                              );
                              try {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .updateProfile(updated);
                                AppToast.showSuccess('Profile updated successfully!');
                              } catch (e) {
                                AppToast.showError('Failed to update profile: $e');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                KompassButton(
                  label: 'Sign Out',
                  icon: Icons.logout,
                  isOutlined: true,
                  isDestructive: true,
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).signOut();
                    AppToast.showInfo('Signed out successfully.');
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const KompassLoading(),
        error: (e, _) => RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
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
