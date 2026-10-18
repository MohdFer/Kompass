import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../storage/hive_service.dart';

/// Service dedicated to handling prompt permission onboarding and GPS service checks.
class AppPermissionService {
  AppPermissionService._();
  static final instance = AppPermissionService._();

  static const String _firstRunKey = 'initial_permissions_requested_v1';
  static const String _batteryDialogKey = 'battery_instruction_shown_v1';
  bool _isGpsDialogShowing = false;
  bool _isBatteryDialogShowing = false;

  /// Prompt for all essential permissions on first install and launch:
  /// 1. Notifications (FCM pushes, Expedition Radio, SOS distress alerts)
  /// 2. Location (Real-time tour tracking, Meeting points, Geofencing safety)
  /// 3. Camera (QR attendance check-in)
  Future<void> requestInitialPermissionsPrompt() async {
    if (kIsWeb) return;

    try {
      final alreadyRequested =
          HiveService.instance.getSetting<bool>(_firstRunKey) ?? false;

      if (!alreadyRequested) {
        debugPrint('AppPermissionService: Prompting all initial permissions on first launch.');

        // Prompt sequentially so the user clearly understands each system dialog
        // 1. Notifications (Android 13+ POST_NOTIFICATIONS)
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }

        // 2. Location (When in use)
        if (await Permission.locationWhenInUse.isDenied) {
          await Permission.locationWhenInUse.request();
        }

        // 3. Camera (QR Scanner)
        if (await Permission.camera.isDenied) {
          await Permission.camera.request();
        }

        // 4. Request Unrestricted Battery Optimization exemption so notifications arrive unattended
        if (await Permission.ignoreBatteryOptimizations.isDenied) {
          await Permission.ignoreBatteryOptimizations.request();
        }

        await HiveService.instance.saveSetting(_firstRunKey, true);
      }
    } catch (e) {
      debugPrint('AppPermissionService requestInitialPermissionsPrompt error: $e');
    }
  }

  /// Request unrestricted battery usage so push notifications and background listeners are not killed.
  Future<bool> requestUnrestrictedBatteryOptimization() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        final result = await Permission.ignoreBatteryOptimizations.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  /// Check if the app is already set to unrestricted battery optimization.
  Future<bool> isBatteryOptimizationIgnored() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Check and prompt user with in-app instructions to set battery setting to Unrestricted on first open after install.
  Future<void> checkAndPromptBatteryOptimization({
    required BuildContext context,
    bool force = false,
  }) async {
    if (kIsWeb) return;

    final alreadyGranted = await isBatteryOptimizationIgnored();
    if (alreadyGranted && !force) return;

    final alreadyShown =
        HiveService.instance.getSetting<bool>(_batteryDialogKey) ?? false;
    if (alreadyShown && !force) return;

    if (!context.mounted || _isBatteryDialogShowing) return;

    _isBatteryDialogShowing = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.battery_charging_full_rounded,
                  color: AppColors.primaryGold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Unrestricted Battery Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To receive Tour Chat, Guide Announcements, and Emergency SOS alerts unattended when your phone is locked or in Battery Saver mode, please set KOMPASS to Unrestricted.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOW TO ENABLE:',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStepRow('1', 'Tap "Configure Now" below'),
                      _buildStepRow('2', 'Select "Battery" or "App Battery Usage"'),
                      _buildStepRow('3', 'Choose "Unrestricted" (or "No restrictions")'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.primaryGold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Xiaomi/Samsung: Also allow Autostart & disable Background Limitations.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryGold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
              },
              child: Text(
                'Later',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.settings, size: 18),
              label: const Text(
                'Configure Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final granted = await requestUnrestrictedBatteryOptimization();
                if (!granted) {
                  await openAppSettings();
                }
              },
            ),
          ],
        ),
      );

      await HiveService.instance.saveSetting(_batteryDialogKey, true);
    } finally {
      _isBatteryDialogShowing = false;
    }
  }

  static Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Check whether GPS (Location Services) is enabled on the device.
  /// If turned off, prompts the user with an interactive dialog asking them to turn it on.
  Future<bool> checkAndPromptGps({
    required BuildContext context,
    String? title,
    String? message,
  }) async {
    if (kIsWeb) return true;

    final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (isGpsEnabled) return true;

    if (!context.mounted || _isGpsDialogShowing) return false;

    _isGpsDialogShowing = true;
    try {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Turn On Location (GPS)',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            message ??
                'GPS is currently turned off on your device.\n\n'
                'KOMPASS requires active GPS to stream your position to your tour group and ensure your safety during active tours.\n\n'
                'Please enable Location in your device settings.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(
                'Not Now',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Turn on GPS'),
              onPressed: () => Navigator.pop(dialogCtx, true),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await Geolocator.openLocationSettings();
      }
    } finally {
      _isGpsDialogShowing = false;
    }

    return await Geolocator.isLocationServiceEnabled();
  }

  /// Helper to check if location permission is granted.
  Future<bool> hasLocationPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }
}
