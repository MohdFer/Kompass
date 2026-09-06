import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Ship\'s Radio'),
      body: Center(child: Text('Chat messages — coming soon')),
    );
  }
}
