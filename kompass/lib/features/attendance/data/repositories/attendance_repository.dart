import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/attendance_model.dart';
import '../models/roll_call_session_model.dart';

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

  /// Clear all attendance records for a tour.
  Future<void> clearAttendance(String tourId) async {
    try {
      final snapshot = await _attendanceRef(tourId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to clear attendance logs: $e');
    }
  }

  /// Delete a single attendance record.
  Future<void> deleteAttendanceRecord(String tourId, String attendanceId) async {
    try {
      await _attendanceRef(tourId).doc(attendanceId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete attendance record: $e');
    }
  }

  DocumentReference<Map<String, dynamic>> _rollCallSessionRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('RollCallSession')
          .doc('active');

  /// Watch active real-time roll call session for a tour.
  Stream<RollCallSessionModel?> watchActiveRollCallSession(String tourId) {
    return _rollCallSessionRef(tourId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return RollCallSessionModel.fromFirestore(doc);
    });
  }

  /// Start a new roll call session with a random 4-digit code and custom expiration duration.
  Future<RollCallSessionModel> createRollCallSession({
    required String tourId,
    required String guideId,
    String? guideName,
    int durationMinutes = 5,
  }) async {
    try {
      final random = Random();
      final code = (1000 + random.nextInt(9000)).toString();
      final now = DateTime.now();
      final expiresAt = now.add(Duration(minutes: durationMinutes));

      final session = RollCallSessionModel(
        code: code,
        createdAt: now,
        expiresAt: expiresAt,
        createdBy: guideId,
        createdByName: guideName,
        isActive: true,
      );

      await _rollCallSessionRef(tourId).set(session.toFirestore());
      return session;
    } catch (e) {
      throw DatabaseException('Failed to create roll call session: $e');
    }
  }

  /// Cancel/end the active roll call session.
  Future<void> endRollCallSession(String tourId) async {
    try {
      await _rollCallSessionRef(tourId).delete();
    } catch (e) {
      throw DatabaseException('Failed to end roll call session: $e');
    }
  }

  /// Verify 4-digit code and mark the participant present.
  Future<void> verifyCodeAndCheckIn({
    required String tourId,
    required String userId,
    required String enteredCode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final doc = await _rollCallSessionRef(tourId).get();
      if (!doc.exists || doc.data() == null) {
        throw const DatabaseException(
          'No active roll call session found. Please wait for your Guide to start one.',
        );
      }

      final session = RollCallSessionModel.fromFirestore(doc);
      if (!session.isActive || session.isExpired) {
        throw const DatabaseException(
          'The roll call code has expired. Please ask your Guide to generate a new session.',
        );
      }

      if (session.code != enteredCode.trim()) {
        throw const DatabaseException(
          'Invalid 4-digit code. Please check the code with your Guide and try again.',
        );
      }

      // Record attendance as Present via Code method
      final record = AttendanceModel(
        attendanceId: '',
        tourId: tourId,
        userId: userId,
        method: 'Code',
        status: 'Present',
        latitude: latitude,
        longitude: longitude,
      );
      await markAttendance(tourId, record);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Check-in failed: $e');
    }
  }
}
