import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  AttendanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _attendanceRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('Attendance');

  /// Record a new attendance entry (QR scan or manual).
  Future<void> markAttendance(String tourId, AttendanceModel record) async {
    try {
      await _attendanceRef(tourId).add(record.toFirestore());
    } catch (e) {
      throw DatabaseException('Failed to mark attendance: $e');
    }
  }

  /// Watch all attendance records for a tour.
  Stream<List<AttendanceModel>> watchAttendance(String tourId) {
    return _attendanceRef(tourId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AttendanceModel.fromFirestore).toList());
  }

  /// Get attendance records for a specific user in a tour.
  Stream<List<AttendanceModel>> watchUserAttendance(
    String tourId,
    String userId,
  ) {
    return _attendanceRef(tourId)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AttendanceModel.fromFirestore).toList());
  }
}
