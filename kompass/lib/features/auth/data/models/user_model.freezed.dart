// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get profileImage => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  bool get isPhoneVerified => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String get emergencyContact => throw _privateConstructorUsedError;
  String get emergencyContactName => throw _privateConstructorUsedError;
  bool get isEmergencyContactVerified => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String userId,
    String name,
    String email,
    String role,
    String profileImage,
    String phoneNumber,
    bool isPhoneVerified,
    String address,
    String gender,
    int? age,
    String emergencyContact,
    String emergencyContactName,
    bool isEmergencyContactVerified,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? profileImage = null,
    Object? phoneNumber = null,
    Object? isPhoneVerified = null,
    Object? address = null,
    Object? gender = null,
    Object? age = freezed,
    Object? emergencyContact = null,
    Object? emergencyContactName = null,
    Object? isEmergencyContactVerified = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImage: null == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            isPhoneVerified: null == isPhoneVerified
                ? _value.isPhoneVerified
                : isPhoneVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            age: freezed == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int?,
            emergencyContact: null == emergencyContact
                ? _value.emergencyContact
                : emergencyContact // ignore: cast_nullable_to_non_nullable
                      as String,
            emergencyContactName: null == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                      as String,
            isEmergencyContactVerified: null == isEmergencyContactVerified
                ? _value.isEmergencyContactVerified
                : isEmergencyContactVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String name,
    String email,
    String role,
    String profileImage,
    String phoneNumber,
    bool isPhoneVerified,
    String address,
    String gender,
    int? age,
    String emergencyContact,
    String emergencyContactName,
    bool isEmergencyContactVerified,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? profileImage = null,
    Object? phoneNumber = null,
    Object? isPhoneVerified = null,
    Object? address = null,
    Object? gender = null,
    Object? age = freezed,
    Object? emergencyContact = null,
    Object? emergencyContactName = null,
    Object? isEmergencyContactVerified = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImage: null == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        isPhoneVerified: null == isPhoneVerified
            ? _value.isPhoneVerified
            : isPhoneVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        age: freezed == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int?,
        emergencyContact: null == emergencyContact
            ? _value.emergencyContact
            : emergencyContact // ignore: cast_nullable_to_non_nullable
                  as String,
        emergencyContactName: null == emergencyContactName
            ? _value.emergencyContactName
            : emergencyContactName // ignore: cast_nullable_to_non_nullable
                  as String,
        isEmergencyContactVerified: null == isEmergencyContactVerified
            ? _value.isEmergencyContactVerified
            : isEmergencyContactVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage = '',
    this.phoneNumber = '',
    this.isPhoneVerified = false,
    this.address = '',
    this.gender = '',
    this.age,
    this.emergencyContact = '',
    this.emergencyContactName = '',
    this.isEmergencyContactVerified = false,
    this.createdAt,
  }) : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String name;
  @override
  final String email;
  @override
  final String role;
  @override
  @JsonKey()
  final String profileImage;
  @override
  @JsonKey()
  final String phoneNumber;
  @override
  @JsonKey()
  final bool isPhoneVerified;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String gender;
  @override
  final int? age;
  @override
  @JsonKey()
  final String emergencyContact;
  @override
  @JsonKey()
  final String emergencyContactName;
  @override
  @JsonKey()
  final bool isEmergencyContactVerified;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, email: $email, role: $role, profileImage: $profileImage, phoneNumber: $phoneNumber, isPhoneVerified: $isPhoneVerified, address: $address, gender: $gender, age: $age, emergencyContact: $emergencyContact, emergencyContactName: $emergencyContactName, isEmergencyContactVerified: $isEmergencyContactVerified, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isPhoneVerified, isPhoneVerified) ||
                other.isPhoneVerified == isPhoneVerified) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(
                  other.isEmergencyContactVerified,
                  isEmergencyContactVerified,
                ) ||
                other.isEmergencyContactVerified ==
                    isEmergencyContactVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    name,
    email,
    role,
    profileImage,
    phoneNumber,
    isPhoneVerified,
    address,
    gender,
    age,
    emergencyContact,
    emergencyContactName,
    isEmergencyContactVerified,
    createdAt,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    required final String userId,
    required final String name,
    required final String email,
    required final String role,
    final String profileImage,
    final String phoneNumber,
    final bool isPhoneVerified,
    final String address,
    final String gender,
    final int? age,
    final String emergencyContact,
    final String emergencyContactName,
    final bool isEmergencyContactVerified,
    final DateTime? createdAt,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get name;
  @override
  String get email;
  @override
  String get role;
  @override
  String get profileImage;
  @override
  String get phoneNumber;
  @override
  bool get isPhoneVerified;
  @override
  String get address;
  @override
  String get gender;
  @override
  int? get age;
  @override
  String get emergencyContact;
  @override
  String get emergencyContactName;
  @override
  bool get isEmergencyContactVerified;
  @override
  DateTime? get createdAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
