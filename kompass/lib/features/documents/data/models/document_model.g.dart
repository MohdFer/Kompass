// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentModelImpl _$$DocumentModelImplFromJson(Map<String, dynamic> json) =>
    _$DocumentModelImpl(
      documentId: json['documentId'] as String,
      tourId: json['tourId'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      uploadedBy: json['uploadedBy'] as String,
      fileType: json['fileType'] as String? ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$DocumentModelImplToJson(_$DocumentModelImpl instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'tourId': instance.tourId,
      'name': instance.name,
      'url': instance.url,
      'uploadedBy': instance.uploadedBy,
      'fileType': instance.fileType,
      'fileSizeBytes': instance.fileSizeBytes,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };
