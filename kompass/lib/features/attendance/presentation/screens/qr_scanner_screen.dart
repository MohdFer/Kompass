import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
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
        await ref.read(attendanceControllerProvider.notifier).markAttendance(
          tourId: widget.tourId,
          userId: scannedUserId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance marked successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid QR code for this tour.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code format.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    // Delay before allowing next scan to prevent multiple scans
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KompassAppBar(title: 'Scan Crew Badge'),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Align QR code within the frame',
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
