import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Scan Crew Badge'),
      body: Center(child: Text('QR Scanner — coming soon')),
    );
  }
}
