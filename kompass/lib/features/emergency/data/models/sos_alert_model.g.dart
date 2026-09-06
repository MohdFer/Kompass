// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SosAlertModelImpl _$$SosAlertModelImplFromJson(Map<String, dynamic> json) =>
    _$SosAlertModelImpl(
      alertId: json['alertId'] as String,
      tourId: json['tourId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String? ?? 'active',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$$SosAlertModelImplToJson(_$SosAlertModelImpl instance) =>
    <String, dynamic>{
      'alertId': instance.alertId,
      'tourId': instance.tourId,
      'userId': instance.userId,
      'userName': instance.userName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'message': instance.message,
      'timestamp': instance.timestamp?.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };
