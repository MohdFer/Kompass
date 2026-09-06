import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Captain\'s Orders'),
      body: Center(child: Text('Announcements — coming soon')),
    );
  }
}
