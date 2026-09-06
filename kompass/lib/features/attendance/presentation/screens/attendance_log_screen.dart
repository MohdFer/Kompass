import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/attendance_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/data/models/user_model.dart';

final userNameProvider = FutureProvider.family<String, String>((ref, userId) async {
  final user = await ref.read(authRepositoryProvider).getUserData(userId);
  return user?.name ?? 'Unknown User';
});

class AttendanceLogScreen extends ConsumerWidget {
  const AttendanceLogScreen({required this.tourId, super.key});
  final String tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(tourAttendanceProvider(tourId));

    return Scaffold(
      appBar: const KompassAppBar(title: 'Roll Call Log'),
      body: attendanceAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final userNameAsync = ref.watch(userNameProvider(record.userId));
              
              final timeString = record.timestamp != null 
                  ? DateFormat('MMM dd, yyyy - hh:mm a').format(record.timestamp!)
                  : 'Unknown time';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryGoldLight,
                    child: Icon(Icons.check, color: AppColors.textOnPrimary),
                  ),
                  title: userNameAsync.when(
                    data: (name) => Text(name, style: AppTextStyles.titleMedium),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Error'),
                  ),
                  subtitle: Text(
                    'Method: ${record.method}\nTime: $timeString',
                    style: AppTextStyles.bodyMedium,
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    record.status,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: record.status == 'Present' ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
