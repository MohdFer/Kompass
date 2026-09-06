// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceModelImpl _$$AttendanceModelImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceModelImpl(
  attendanceId: json['attendanceId'] as String,
  tourId: json['tourId'] as String,
  userId: json['userId'] as String,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  method: json['method'] as String? ?? 'QR',
  status: json['status'] as String? ?? 'Present',
);

Map<String, dynamic> _$$AttendanceModelImplToJson(
  _$AttendanceModelImpl instance,
) => <String, dynamic>{
  'attendanceId': instance.attendanceId,
  'tourId': instance.tourId,
  'userId': instance.userId,
  'timestamp': instance.timestamp?.toIso8601String(),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'method': instance.method,
  'status': instance.status,
};
