import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/attendance_model.dart';
import '../data/repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final tourAttendanceProvider =
    StreamProvider.family<List<AttendanceModel>, String>((ref, tourId) {
  return ref.watch(attendanceRepositoryProvider).watchAttendance(tourId);
});
