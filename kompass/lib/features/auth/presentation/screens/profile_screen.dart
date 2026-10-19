import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../services/notifications/web_notification_helper.dart';
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

  Future<void> _showSetPasswordDialog(
    BuildContext context, {
    required bool isUpdating,
    required String email,
  }) async {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isUpdating ? 'Change Account Password' : 'Link / Set Password',
              style: AppTextStyles.headlineLarge,
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUpdating
                          ? 'Enter a new password for $email.'
                          : 'Set a password for $email. This allows you to sign in using either Google or your email and password directly.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: obscurePassword,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                        ),
                      ),
                      obscureText: obscureConfirm,
                      validator: (val) =>
                          Validators.confirmPassword(val, passwordController.text),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setDialogState(() => isSubmitting = true);
                          try {
                            await ref
                                .read(authControllerProvider.notifier)
                                .linkPassword(passwordController.text.trim());
                            if (!context.mounted) return;
                            Navigator.of(dialogCtx).pop();
                            AppToast.showSuccess(
                              isUpdating
                                  ? 'Password updated successfully!'
                                  : 'Password set! You can now log in with either Google or your password.',
                            );
                            setState(() {});
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            AppToast.showError(e.toString(), context: context);
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(isUpdating ? 'Update Password' : 'Save Password'),
              ),
            ],
          );
        },
      ),
    );

    passwordController.dispose();
    confirmPasswordController.dispose();
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
          final firebaseUser = FirebaseAuth.instance.currentUser;
          final providers = firebaseUser?.providerData.map((p) => p.providerId).toList() ?? [];
          final isGoogleLinked = providers.contains('google.com');
          final isPasswordLinked = providers.contains('password');
          final isEmailVerified = firebaseUser?.emailVerified ?? false;

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
                        if (kIsWeb)
                          Builder(
                            builder: (context) {
                              final status = NotificationService.instance.getWebPermissionStatus();
                              final isGranted = status == WebNotificationPermission.granted;
                              final isDenied = status == WebNotificationPermission.denied;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  isGranted
                                      ? Icons.notifications_active_rounded
                                      : (isDenied
                                          ? Icons.notifications_off_rounded
                                          : Icons.notifications_none_rounded),
                                  color: isGranted
                                      ? const Color(0xFF00E676)
                                      : (isDenied
                                          ? const Color(0xFFFF5252)
                                          : AppColors.primaryGold),
                                ),
                                title: const Text('Web Notifications'),
                                subtitle: Text(
                                  isGranted
                                      ? 'Active & enabled • Prompt alerts for expedition chat, broadcasts, and SOS distress beacons.'
                                      : (isDenied
                                          ? 'Blocked in browser settings • Allow notifications in your browser address bar.'
                                          : 'Turn on notifications to receive prompt alerts even when minimized.'),
                                ),
                                trailing: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isGranted
                                        ? const Color(0xFF00E676)
                                        : AppColors.primaryGold,
                                    side: BorderSide(
                                      color: isGranted
                                          ? const Color(0xFF00E676)
                                          : AppColors.primaryGold,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onPressed: () async {
                                    if (isGranted) {
                                      await NotificationService.instance.showNotification(
                                        id: 8888,
                                        title: '🧭 KOMPASS Notification Test',
                                        body: 'Web notifications are promptly active and working!',
                                        payload: 'test',
                                      );
                                      AppToast.showSuccess('Test notification dispatched!');
                                    } else if (isDenied) {
                                      AppToast.showWarning(
                                        'Notifications are blocked in your browser. Click the lock/info icon beside the URL in the address bar and set Notifications to "Allow".',
                                        duration: const Duration(seconds: 6),
                                      );
                                    } else {
                                      final granted = await NotificationService.instance.requestWebNotificationPermission();
                                      if (mounted) setState(() {});
                                      if (granted) {
                                        AppToast.showSuccess('Web notifications enabled successfully!');
                                        await NotificationService.instance.showNotification(
                                          id: 8888,
                                          title: '🧭 KOMPASS Notifications Enabled',
                                          body: 'You will now receive prompt tour alerts directly on your screen.',
                                          payload: 'welcome',
                                        );
                                      } else {
                                        AppToast.showInfo('Notification permission was not granted.');
                                      }
                                    }
                                  },
                                  child: Text(isGranted ? 'Test' : (isDenied ? 'Guide' : 'Enable')),
                                ),
                              );
                            },
                          )
                        else
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
                KompassCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.security,
                            color: AppColors.primaryGold,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Login Methods & Security',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your sign-in methods. You can keep both Google Sign-In and Password authentication active at the same time for this account.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Email Verification Row
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isEmailVerified
                              ? Icons.mark_email_read
                              : Icons.mark_email_unread_outlined,
                          color: isEmailVerified ? Colors.green : AppColors.primaryGold,
                        ),
                        title: Text(
                          'Email Verification',
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          isEmailVerified
                              ? 'Verified'
                              : 'Unverified — verify to secure and link your credentials',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isEmailVerified
                                ? Colors.green
                                : AppColors.textSecondary,
                          ),
                        ),
                        trailing: isEmailVerified
                            ? const Chip(
                                label: Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                backgroundColor: Color(0x1F4CAF50),
                              )
                            : OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryGold,
                                  side: const BorderSide(
                                    color: AppColors.primaryGold,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .sendEmailVerification();
                                    AppToast.showSuccess(
                                      'Verification email sent to ${user.email}. Please check your inbox.',
                                    );
                                  } catch (e) {
                                    AppToast.showError(
                                      'Failed to send verification: $e',
                                    );
                                  }
                                },
                                child: const Text('Verify Email'),
                              ),
                      ),
                      const Divider(color: AppColors.border, height: 16),
                      // Google Sign-In Row
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.g_mobiledata,
                          color: Color(0xFF4285F4),
                          size: 32,
                        ),
                        title: Text(
                          'Google Sign-In',
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          isGoogleLinked
                              ? 'Connected (${user.email})'
                              : 'Not linked to Google',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isGoogleLinked
                                ? Colors.green
                                : AppColors.textSecondary,
                          ),
                        ),
                        trailing: isGoogleLinked
                            ? const Chip(
                                label: Text(
                                  'Connected',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                backgroundColor: Color(0x1F4CAF50),
                              )
                            : const Text(
                                'Not linked',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                      const Divider(color: AppColors.border, height: 16),
                      // Email & Password Row
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isPasswordLinked
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          color: isPasswordLinked
                              ? Colors.green
                              : AppColors.primaryGold,
                        ),
                        title: Text(
                          'Email & Password Login',
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          isPasswordLinked
                              ? 'Password set (both Google & password logins work)'
                              : 'No password set (Google login only)',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isPasswordLinked
                                ? AppColors.textSecondary
                                : AppColors.primaryGold,
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPasswordLinked
                                ? AppColors.surfaceVariant
                                : AppColors.primaryGold,
                            foregroundColor: isPasswordLinked
                                ? AppColors.textPrimary
                                : Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _showSetPasswordDialog(
                            context,
                            isUpdating: isPasswordLinked,
                            email: user.email,
                          ),
                          child: Text(
                            isPasswordLinked
                                ? 'Change Password'
                                : 'Set Password',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
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
