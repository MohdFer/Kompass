// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParticipantModelImpl _$$ParticipantModelImplFromJson(
  Map<String, dynamic> json,
) => _$ParticipantModelImpl(
  participantId: json['participantId'] as String,
  tourId: json['tourId'] as String,
  userId: json['userId'] as String,
  role: json['role'] as String? ?? 'Participant',
  status: json['status'] as String? ?? 'Active',
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$$ParticipantModelImplToJson(
  _$ParticipantModelImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'tourId': instance.tourId,
  'userId': instance.userId,
  'role': instance.role,
  'status': instance.status,
  'joinedAt': instance.joinedAt?.toIso8601String(),
};
