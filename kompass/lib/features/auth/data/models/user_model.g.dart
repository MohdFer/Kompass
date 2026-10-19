// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profileImage: json['profileImage'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      address: json['address'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      age: (json['age'] as num?)?.toInt(),
      emergencyContact: json['emergencyContact'] as String? ?? '',
      emergencyContactName: json['emergencyContactName'] as String? ?? '',
      isEmergencyContactVerified:
          json['isEmergencyContactVerified'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'profileImage': instance.profileImage,
      'phoneNumber': instance.phoneNumber,
      'isPhoneVerified': instance.isPhoneVerified,
      'address': instance.address,
      'gender': instance.gender,
      'age': instance.age,
      'emergencyContact': instance.emergencyContact,
      'emergencyContactName': instance.emergencyContactName,
      'isEmergencyContactVerified': instance.isEmergencyContactVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
