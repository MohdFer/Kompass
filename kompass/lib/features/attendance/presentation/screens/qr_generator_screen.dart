import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class QRGeneratorScreen extends StatelessWidget {
  const QRGeneratorScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Your Crew Badge'),
      body: Center(child: Text('QR Code display — coming soon')),
    );
  }
}
