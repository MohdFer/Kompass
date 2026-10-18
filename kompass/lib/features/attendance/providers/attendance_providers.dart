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

final userTourAttendanceProvider =
    StreamProvider.family<List<AttendanceModel>, Map<String, String>>((ref, params) {
  return ref.watch(attendanceRepositoryProvider).watchUserAttendance(params['tourId']!, params['userId']!);
});

final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AsyncValue<void>>((ref) {
  return AttendanceController(ref);
});

class AttendanceController extends StateNotifier<AsyncValue<void>> {
  AttendanceController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> markAttendance({
    required String tourId,
    required String userId,
    String method = 'QR',
    String status = 'Present',
    double? latitude,
    double? longitude,
  }) async {
    try {
      state = const AsyncValue.loading();
      final record = AttendanceModel(
        attendanceId: '',
        tourId: tourId,
        userId: userId,
        method: method,
        status: status,
        latitude: latitude,
        longitude: longitude,
      );
      await ref.read(attendanceRepositoryProvider).markAttendance(tourId, record);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> clearAttendance(String tourId) async {
    try {
      state = const AsyncValue.loading();
      await ref.read(attendanceRepositoryProvider).clearAttendance(tourId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRecord(String tourId, String attendanceId) async {
    try {
      state = const AsyncValue.loading();
      await ref
          .read(attendanceRepositoryProvider)
          .deleteAttendanceRecord(tourId, attendanceId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
