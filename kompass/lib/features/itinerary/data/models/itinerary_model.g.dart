// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItineraryModelImpl _$$ItineraryModelImplFromJson(Map<String, dynamic> json) =>
    _$ItineraryModelImpl(
      itineraryId: json['itineraryId'] as String,
      tourId: json['tourId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ItineraryModelImplToJson(
  _$ItineraryModelImpl instance,
) => <String, dynamic>{
  'itineraryId': instance.itineraryId,
  'tourId': instance.tourId,
  'title': instance.title,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'activities': instance.activities,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$ActivityItemImpl _$$ActivityItemImplFromJson(Map<String, dynamic> json) =>
    _$ActivityItemImpl(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      locationName: json['locationName'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ActivityItemImplToJson(_$ActivityItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'locationName': instance.locationName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
