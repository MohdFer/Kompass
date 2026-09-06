import 'package:flutter/material.dart';
import '../../../../core/widgets/kompass_app_bar.dart';

class AttendanceLogScreen extends StatelessWidget {
  const AttendanceLogScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KompassAppBar(title: 'Roll Call Log'),
      body: Center(child: Text('Attendance records — coming soon')),
    );
  }
}
