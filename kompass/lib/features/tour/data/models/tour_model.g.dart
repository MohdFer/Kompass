// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TourModelImpl _$$TourModelImplFromJson(Map<String, dynamic> json) =>
    _$TourModelImpl(
      tourId: json['tourId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      guideId: json['guideId'] as String,
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'Draft',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TourModelImplToJson(_$TourModelImpl instance) =>
    <String, dynamic>{
      'tourId': instance.tourId,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'guideId': instance.guideId,
      'participantIds': instance.participantIds,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
