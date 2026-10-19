import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_empty_state.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../location/data/models/location_model.dart';
import '../../../location/providers/location_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../../../services/notifications/fcm_direct_dispatcher.dart';
import '../../data/models/sos_alert_model.dart';
import '../../providers/emergency_providers.dart';
import '../../../../services/calling/zego_call_service.dart';

class SOSScreen extends ConsumerWidget {
  const SOSScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final tour = ref.watch(tourDetailProvider(tourId)).valueOrNull;
    final isGuide = user?.userRole == UserRole.guide ||
        user?.userRole == UserRole.admin ||
        (tour != null && user != null && tour.canManageTour(user.userId));

    final alertsAsync = ref.watch(activeSOSAlertsProvider(tourId));

    Future<void> onRefresh() async {
      ref.invalidate(activeSOSAlertsProvider(tourId));
      ref.invalidate(tourDetailProvider(tourId));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    return Scaffold(
      appBar: KompassAppBar(
        title: 'Emergency SOS & Distress',
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View Live Tour Map',
            onPressed: () => context.push('/tours/$tourId/map'),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: KompassLoading(message: 'Checking distress signals...')),
        error: (e, _) => RefreshIndicator(
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
        data: (activeAlerts) {
          return RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ── Active Distress Signals Section (Visible to Guides AND Participants) ──
                if (activeAlerts.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.error, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        'ACTIVE DISTRESS SIGNALS (${activeAlerts.length})',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...activeAlerts.map(
                    (alert) => _buildAlertCard(context, ref, alert, user?.userId, isGuide),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                ],

                // ── Panic Trigger / Ready View ──
                if (activeAlerts.isEmpty && isGuide) ...[
                  const SizedBox(height: 32),
                  const KompassEmptyState(
                    title: 'All Clear on Expedition',
                    message: 'No active SOS alerts in this tour right now. All crew members are reported safe.',
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 32),
                ],

                // ── Panic Button Component for Triggering Emergency ──
                _PanicTriggerSection(
                  tourId: tourId,
                  tourName: tour?.name ?? 'Tour',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    WidgetRef ref,
    SosAlertModel alert,
    String? currentUserId,
    bool isGuide,
  ) {
    final isMyAlert = alert.userId == currentUserId;
    final timeStr = alert.timestamp != null
        ? DateFormat('MMM dd, hh:mm a').format(alert.timestamp!)
        : 'Just now';

    final hasCoords = alert.latitude != 0.0 || alert.longitude != 0.0;

    return Card(
      color: AppColors.error.withValues(alpha: 0.12),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.error, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sos, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyAlert ? 'YOUR ACTIVE SOS BEACON' : 'DISTRESS: ${alert.userName}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                alert.message.isNotEmpty
                    ? alert.message
                    : 'Emergency assistance requested!',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.primaryGold),
                const SizedBox(width: 4),
                Text(
                  hasCoords
                      ? 'GPS: ${alert.latitude.toStringAsFixed(5)}, ${alert.longitude.toStringAsFixed(5)}'
                      : 'GPS: Live coordinates pending fix',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGoldLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sosRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.phone_in_talk, size: 18),
                    label: const Text('Emergency Voice'),
                    onPressed: () {
                      ZegoCallService.instance.sendCallInvitation(
                        context: context,
                        targetUserId: alert.userId,
                        targetUserName: alert.userName,
                        isVideo: false,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.sosRed),
                      foregroundColor: AppColors.sosRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.videocam, size: 18),
                    label: const Text('SOS Video'),
                    onPressed: () {
                      ZegoCallService.instance.sendCallInvitation(
                        context: context,
                        targetUserId: alert.userId,
                        targetUserName: alert.userName,
                        isVideo: true,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGold),
                      foregroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Locate on Map'),
                    onPressed: () => context.push('/tours/$tourId/map'),
                  ),
                ),
                if (isGuide || isMyAlert) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(isMyAlert ? 'I Am Safe' : 'Resolve SOS'),
                      onPressed: () async {
                        try {
                          await ref
                              .read(emergencyRepositoryProvider)
                              .resolveSOS(tourId, alert.alertId);
                          AppToast.showSuccess('SOS Alert marked as resolved.');
                        } catch (e) {
                          AppToast.showError('Failed to resolve SOS: $e');
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PanicTriggerSection extends ConsumerStatefulWidget {
  const _PanicTriggerSection({
    required this.tourId,
    required this.tourName,
  });
  final String tourId;
  final String tourName;

  @override
  ConsumerState<_PanicTriggerSection> createState() =>
      _PanicTriggerSectionState();
}

class _PanicTriggerSectionState extends ConsumerState<_PanicTriggerSection> {
  bool _isBroadcasting = false;

  final List<String> _emergencyReasons = const [
    'Immediate General Assistance',
    'Medical Emergency / Need Doctor',
    'Lost / Separated from Expedition',
    'Physical Hazard / Injury',
    'Severe Weather / Danger',
  ];

  Future<void> _handlePanicPressed() async {
    String selectedReason = _emergencyReasons.first;
    final noteController = TextEditingController();

    final shouldBroadcast = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFFF0000)),
              SizedBox(width: 8),
              Text('Confirm SOS Distress'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will immediately broadcast a critical alert to the Tour Guide and all participants with your live GPS location.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 14),
                Text('Emergency Type:', style: AppTextStyles.labelMedium),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  isExpanded: true,
                  items: _emergencyReasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedReason = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Additional note (optional)',
                    hintText: 'e.g. Near milestone 4, left ankle sprain',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('BROADCAST SOS NOW'),
            ),
          ],
        ),
      ),
    );

    if (shouldBroadcast != true) return;

    final customNote = noteController.text.trim();
    final fullMessage = customNote.isNotEmpty
        ? '$selectedReason: $customNote'
        : selectedReason;

    await _broadcastSOS(fullMessage);
  }

  Future<void> _broadcastSOS(String message) async {
    setState(() => _isBroadcasting = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      final authUser = ref.read(authStateChangesProvider).valueOrNull;

      if (authUser == null) {
        AppToast.showError('User session expired. Please sign in again.');
        return;
      }

      double latitude = 0.0;
      double longitude = 0.0;

      // 1. Acquire high-accuracy GPS coordinates immediately
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 6),
              ),
            );
            latitude = pos.latitude;
            longitude = pos.longitude;
          }
        }
      } catch (e) {
        debugPrint('SOS GPS acquisition skipped/error: $e');
      }

      // 2. Publish emergency pin to Locations collection for instant Live Map visibility
      if (latitude != 0.0 || longitude != 0.0) {
        try {
          final loc = LocationModel(
            locationId: '${widget.tourId}_${authUser.uid}',
            tourId: widget.tourId,
            userId: authUser.uid,
            latitude: latitude,
            longitude: longitude,
            userName: '🚨 ${user?.name ?? 'Explorer'} (SOS)',
          );
          await ref.read(locationRepositoryProvider).saveLocation(loc);
        } catch (_) {}
      }

      // 3. Trigger emergency record in Firestore
      final alert = SosAlertModel(
        alertId: '',
        tourId: widget.tourId,
        userId: authUser.uid,
        userName: user?.name ?? 'Participant',
        latitude: latitude,
        longitude: longitude,
        message: message,
      );

      final alertId = await ref.read(emergencyRepositoryProvider).triggerSOS(widget.tourId, alert);

      // 4. Dispatch direct high-priority FCM emergency push to all tour members & guide
      unawaited(
        FcmDirectDispatcher.instance.sendSosDistress(
          tourId: widget.tourId,
          tourName: widget.tourName,
          userName: user?.name ?? 'Explorer',
          reason: message,
          senderId: authUser.uid,
          alertId: alertId,
          latitude: latitude,
          longitude: longitude,
        ).catchError((err) {
          debugPrint('FCM direct send SOS error: $err');
        }),
      );

      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}

      AppToast.showError(
        'SOS Beacon Sent! Guide and all tour crew members notified with your details.',
        title: 'DISTRESS SIGNAL BROADCASTED',
        duration: const Duration(seconds: 7),
      );
    } catch (e) {
      AppToast.showError('Failed to broadcast SOS alert: $e');
    } finally {
      if (mounted) setState(() => _isBroadcasting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'In case of emergency, tap the PANIC button below.\nYour details and GPS location will be broadcast to the guide and all participants.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: _isBroadcasting ? null : _handlePanicPressed,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFF3B30),
                    Color(0xFFB00020),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.55),
                    blurRadius: 36,
                    spreadRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isBroadcasting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 36),
                        SizedBox(height: 6),
                        Text(
                          'PANIC',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'TAP TO SEND SOS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
