// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParticipantModel _$ParticipantModelFromJson(Map<String, dynamic> json) {
  return _ParticipantModel.fromJson(json);
}

/// @nodoc
mixin _$ParticipantModel {
  String get participantId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this ParticipantModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantModelCopyWith<ParticipantModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantModelCopyWith<$Res> {
  factory $ParticipantModelCopyWith(
    ParticipantModel value,
    $Res Function(ParticipantModel) then,
  ) = _$ParticipantModelCopyWithImpl<$Res, ParticipantModel>;
  @useResult
  $Res call({
    String participantId,
    String tourId,
    String userId,
    String role,
    String status,
    DateTime? joinedAt,
  });
}

/// @nodoc
class _$ParticipantModelCopyWithImpl<$Res, $Val extends ParticipantModel>
    implements $ParticipantModelCopyWith<$Res> {
  _$ParticipantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? tourId = null,
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            participantId: null == participantId
                ? _value.participantId
                : participantId // ignore: cast_nullable_to_non_nullable
                      as String,
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParticipantModelImplCopyWith<$Res>
    implements $ParticipantModelCopyWith<$Res> {
  factory _$$ParticipantModelImplCopyWith(
    _$ParticipantModelImpl value,
    $Res Function(_$ParticipantModelImpl) then,
  ) = __$$ParticipantModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String participantId,
    String tourId,
    String userId,
    String role,
    String status,
    DateTime? joinedAt,
  });
}

/// @nodoc
class __$$ParticipantModelImplCopyWithImpl<$Res>
    extends _$ParticipantModelCopyWithImpl<$Res, _$ParticipantModelImpl>
    implements _$$ParticipantModelImplCopyWith<$Res> {
  __$$ParticipantModelImplCopyWithImpl(
    _$ParticipantModelImpl _value,
    $Res Function(_$ParticipantModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? tourId = null,
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = freezed,
  }) {
    return _then(
      _$ParticipantModelImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as String,
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParticipantModelImpl extends _ParticipantModel {
  const _$ParticipantModelImpl({
    required this.participantId,
    required this.tourId,
    required this.userId,
    this.role = 'Participant',
    this.status = 'Active',
    this.joinedAt,
  }) : super._();

  factory _$ParticipantModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantModelImplFromJson(json);

  @override
  final String participantId;
  @override
  final String tourId;
  @override
  final String userId;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? joinedAt;

  @override
  String toString() {
    return 'ParticipantModel(participantId: $participantId, tourId: $tourId, userId: $userId, role: $role, status: $status, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantModelImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    participantId,
    tourId,
    userId,
    role,
    status,
    joinedAt,
  );

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantModelImplCopyWith<_$ParticipantModelImpl> get copyWith =>
      __$$ParticipantModelImplCopyWithImpl<_$ParticipantModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantModelImplToJson(this);
  }
}

abstract class _ParticipantModel extends ParticipantModel {
  const factory _ParticipantModel({
    required final String participantId,
    required final String tourId,
    required final String userId,
    final String role,
    final String status,
    final DateTime? joinedAt,
  }) = _$ParticipantModelImpl;
  const _ParticipantModel._() : super._();

  factory _ParticipantModel.fromJson(Map<String, dynamic> json) =
      _$ParticipantModelImpl.fromJson;

  @override
  String get participantId;
  @override
  String get tourId;
  @override
  String get userId;
  @override
  String get role;
  @override
  String get status;
  @override
  DateTime? get joinedAt;

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantModelImplCopyWith<_$ParticipantModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
