import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Treasure Map'),
      body: Center(child: Text('Map view — coming soon')),
    );
  }
}
