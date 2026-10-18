import 'dart:math' as math;
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
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _isFrontCamera = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
      if (mounted) {
        setState(() {
          _isFrontCamera = !_isFrontCamera;
          if (_isFrontCamera) {
            _isTorchOn = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError('Unable to switch camera: $e', context: context);
      }
    }
  }

  Future<void> _toggleTorch() async {
    if (_isFrontCamera) {
      AppToast.showInfo(
        'Flashlight is only available on the rear camera.',
        context: context,
      );
      return;
    }
    try {
      await _scannerController.toggleTorch();
      if (mounted) {
        setState(() => _isTorchOn = !_isTorchOn);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showWarning('Flashlight not supported on this device.');
      }
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final tour = ref.read(tourDetailProvider(widget.tourId)).valueOrNull;
    final canScan = currentUser != null &&
        tour != null &&
        tour.canManageTour(currentUser.userId);

    if (!canScan) {
      if (mounted) {
        AppToast.showError(
          'Only the Tour Guide or a Guest Guide can scan attendance QR codes.',
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
        appBar: KompassAppBar(title: 'Scan Crew Badge'),
        body: KompassLoading(message: 'Verifying Guide permissions...'),
      );
    }

    final currentUser = userAsync.valueOrNull;
    final tour = tourAsync.valueOrNull;
    final canScan = currentUser != null &&
        tour != null &&
        tour.canManageTour(currentUser.userId);

    if (!canScan) {
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
                  'Access Restricted: Only the Tour Guide or a Guest Guide of this tour can scan QR badges and mark attendance.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: KompassAppBar(
        title: 'Scan Crew Badge',
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? AppColors.primaryGold : Colors.white,
            ),
            tooltip: _isTorchOn ? 'Turn Off Flashlight' : 'Turn On Flashlight',
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
            tooltip: _isFrontCamera
                ? 'Switch to Back Camera'
                : 'Switch to Front Camera',
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Feed
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // 2. GPay-style Cutout & 4-Color Corner Alignment Frame
          const IgnorePointer(
            child: CustomPaint(
              painter: _GPayScannerOverlayPainter(
                boxSize: 268,
                borderRadius: 28,
              ),
            ),
          ),

          // 3. Processing Indicator inside the frame
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryGold),
                    SizedBox(height: 12),
                    Text(
                      'Verifying Crew Badge...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Bottom Instruction & Quick Camera Switch Controls
          Positioned(
            bottom: 36,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: const Text(
                    'Place participant QR badge inside the box',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: const BorderSide(
                            color: AppColors.primaryGold,
                            width: 1.2,
                          ),
                        ),
                      ),
                      onPressed: _switchCamera,
                      icon: const Icon(
                        Icons.cameraswitch_rounded,
                        size: 20,
                        color: AppColors.primaryGold,
                      ),
                      label: Text(
                        _isFrontCamera
                            ? 'Front Cam Active • Switch to Back'
                            : 'Back Cam Active • Switch to Front',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a Google Pay–inspired scanner overlay with a dark translucent mask,
/// a rounded-square transparent cutout in the center, and 4 colored corner brackets.
class _GPayScannerOverlayPainter extends CustomPainter {
  const _GPayScannerOverlayPainter({
    required this.boxSize,
    required this.borderRadius,
  });

  final double boxSize;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 28);
    final scanRect = Rect.fromCenter(
      center: center,
      width: boxSize,
      height: boxSize,
    );
    final scanRRect = RRect.fromRectAndRadius(
      scanRect,
      Radius.circular(borderRadius),
    );

    // 1. Dark translucent overlay outside the scan box
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(scanRRect);
    final maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(
      maskPath,
      Paint()..color = Colors.black.withValues(alpha: 0.62),
    );

    // 2. Subtle inner white guide border
    canvas.drawRRect(
      scanRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 3. Four bold rounded GPay-style corner brackets
    const double strokeWidth = 6.5;
    const double armLength = 34.0;
    final double r = borderRadius;

    Paint cornerPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top-Left Corner (Red - #EA4335)
    final topLeftPath = Path()
      ..moveTo(scanRect.left, scanRect.top + r + armLength)
      ..lineTo(scanRect.left, scanRect.top + r)
      ..arcTo(
        Rect.fromLTWH(scanRect.left, scanRect.top, r * 2, r * 2),
        math.pi,
        math.pi / 2,
        false,
      )
      ..lineTo(scanRect.left + r + armLength, scanRect.top);
    canvas.drawPath(topLeftPath, cornerPaint(const Color(0xFFEA4335)));

    // Top-Right Corner (Yellow/Gold - #FBBC04)
    final topRightPath = Path()
      ..moveTo(scanRect.right - r - armLength, scanRect.top)
      ..lineTo(scanRect.right - r, scanRect.top)
      ..arcTo(
        Rect.fromLTWH(scanRect.right - r * 2, scanRect.top, r * 2, r * 2),
        -math.pi / 2,
        math.pi / 2,
        false,
      )
      ..lineTo(scanRect.right, scanRect.top + r + armLength);
    canvas.drawPath(topRightPath, cornerPaint(const Color(0xFFFBBC04)));

    // Bottom-Right Corner (Green - #34A853)
    final bottomRightPath = Path()
      ..moveTo(scanRect.right, scanRect.bottom - r - armLength)
      ..lineTo(scanRect.right, scanRect.bottom - r)
      ..arcTo(
        Rect.fromLTWH(
          scanRect.right - r * 2,
          scanRect.bottom - r * 2,
          r * 2,
          r * 2,
        ),
        0,
        math.pi / 2,
        false,
      )
      ..lineTo(scanRect.right - r - armLength, scanRect.bottom);
    canvas.drawPath(bottomRightPath, cornerPaint(const Color(0xFF34A853)));

    // Bottom-Left Corner (Blue - #4285F4)
    final bottomLeftPath = Path()
      ..moveTo(scanRect.left + r + armLength, scanRect.bottom)
      ..lineTo(scanRect.left + r, scanRect.bottom)
      ..arcTo(
        Rect.fromLTWH(
          scanRect.left,
          scanRect.bottom - r * 2,
          r * 2,
          r * 2,
        ),
        math.pi / 2,
        math.pi / 2,
        false,
      )
      ..lineTo(scanRect.left, scanRect.bottom - r - armLength);
    canvas.drawPath(bottomLeftPath, cornerPaint(const Color(0xFF4285F4)));
  }

  @override
  bool shouldRepaint(covariant _GPayScannerOverlayPainter oldDelegate) {
    return oldDelegate.boxSize != boxSize ||
        oldDelegate.borderRadius != borderRadius;
  }
}
