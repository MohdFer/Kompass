// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      messageId: json['messageId'] as String,
      tourId: json['tourId'] as String,
      senderId: json['senderId'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String? ?? 'text',
      senderName: json['senderName'] as String? ?? '',
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'tourId': instance.tourId,
      'senderId': instance.senderId,
      'message': instance.message,
      'timestamp': instance.timestamp?.toIso8601String(),
      'type': instance.type,
      'senderName': instance.senderName,
    };
