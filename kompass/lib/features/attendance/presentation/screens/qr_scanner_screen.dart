import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_loading.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../providers/attendance_providers.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({required this.tourId, super.key});
  final String tourId;

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final tour = ref.read(tourDetailProvider(widget.tourId)).valueOrNull;
    final isGuideForTour = currentUser != null &&
        tour != null &&
        tour.guideId == currentUser.userId;

    if (!isGuideForTour) {
      if (mounted) {
        AppToast.showError(
          'Only the Tour Guide can scan attendance QR codes.',
          context: context,
        );
      }
      return;
    }

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcodeValue = barcodes.first.rawValue;
    if (barcodeValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    final parts = barcodeValue.split('|');
    if (parts.length == 2) {
      final scannedUserId = parts[0];
      final scannedTourId = parts[1];

      if (scannedTourId == widget.tourId) {
        try {
          await ref.read(attendanceControllerProvider.notifier).markAttendance(
                tourId: widget.tourId,
                userId: scannedUserId,
                method: 'QR',
              );

          if (mounted) {
            AppToast.showSuccess(
              'Attendance marked successfully via QR scan!',
              context: context,
            );
          }
        } catch (e) {
          if (mounted) {
            AppToast.showError(
              'Failed to mark attendance: $e',
              context: context,
            );
          }
        }
      } else {
        if (mounted) {
          AppToast.showWarning(
            'Invalid QR code for this tour.',
            context: context,
          );
        }
      }
    } else {
      if (mounted) {
        AppToast.showWarning(
          'Invalid QR code format.',
          context: context,
        );
      }
    }

    // Delay before allowing next scan to prevent duplicate scans
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final tourAsync = ref.watch(tourDetailProvider(widget.tourId));

    if (userAsync.isLoading || tourAsync.isLoading) {
      return const Scaffold(
        appBar: KompassAppBar(title: 'Scan Crew Badge (Guide Only)'),
        body: KompassLoading(message: 'Verifying Tour Guide permissions...'),
      );
    }

    final currentUser = userAsync.valueOrNull;
    final tour = tourAsync.valueOrNull;
    final isGuideForTour = currentUser != null &&
        tour != null &&
        tour.guideId == currentUser.userId;

    if (!isGuideForTour) {
      return const Scaffold(
        appBar: KompassAppBar(title: 'Scan Crew Badge'),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 64, color: AppColors.error),
                SizedBox(height: 16),
                Text(
                  'Access Restricted: Only the Tour Guide of this tour can scan QR badges and mark attendance.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const KompassAppBar(title: 'Scan Crew Badge (Guide Only)'),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Align Participant QR code within the frame',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
