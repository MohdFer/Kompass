import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/attendance_method.dart';
import '../../../../core/enums/attendance_status.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
abstract class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    required String attendanceId,
    required String tourId,
    required String userId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    @Default('QR') String method,
    @Default('Present') String status,
  }) = _AttendanceModel;

  const AttendanceModel._();

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  static AttendanceModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AttendanceModel.fromJson({
      ...data,
      'attendanceId': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('attendanceId');
    json['timestamp'] = timestamp != null
        ? Timestamp.fromDate(timestamp!)
        : FieldValue.serverTimestamp();
    return json;
  }

  AttendanceMethod get attendanceMethod =>
      AttendanceMethod.fromString(method);
  AttendanceStatus get attendanceStatus =>
      AttendanceStatus.fromString(status);
}
