// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnouncementModelImpl _$$AnnouncementModelImplFromJson(
  Map<String, dynamic> json,
) => _$AnnouncementModelImpl(
  announcementId: json['announcementId'] as String,
  tourId: json['tourId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  createdBy: json['createdBy'] as String,
  createdByName: json['createdByName'] as String? ?? '',
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$AnnouncementModelImplToJson(
  _$AnnouncementModelImpl instance,
) => <String, dynamic>{
  'announcementId': instance.announcementId,
  'tourId': instance.tourId,
  'title': instance.title,
  'message': instance.message,
  'createdBy': instance.createdBy,
  'createdByName': instance.createdByName,
  'timestamp': instance.timestamp?.toIso8601String(),
};
