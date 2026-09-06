import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Voyage Itinerary'),
      body: Center(child: Text('Itinerary timeline — coming soon')),
    );
  }
}
