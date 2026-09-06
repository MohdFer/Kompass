import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class CreateTourScreen extends StatelessWidget {
  const CreateTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Chart a New Course'),
      body: Center(child: Text('Tour creation form — coming soon')),
    );
  }
}
