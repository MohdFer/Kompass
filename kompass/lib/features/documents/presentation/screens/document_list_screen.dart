import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class DocumentListScreen extends StatelessWidget {
  const DocumentListScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Scrolls & Charts'),
      body: Center(child: Text('Documents — coming soon')),
    );
  }
}
