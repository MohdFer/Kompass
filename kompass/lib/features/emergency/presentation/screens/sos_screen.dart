import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Distress Signals'),
      body: Center(child: Text('SOS alerts — coming soon')),
    );
  }
}
