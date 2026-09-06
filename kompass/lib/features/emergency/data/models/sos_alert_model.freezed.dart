// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sos_alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SosAlertModel _$SosAlertModelFromJson(Map<String, dynamic> json) {
  return _SosAlertModel.fromJson(json);
}

/// @nodoc
mixin _$SosAlertModel {
  String get alertId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Serializes this SosAlertModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SosAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SosAlertModelCopyWith<SosAlertModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SosAlertModelCopyWith<$Res> {
  factory $SosAlertModelCopyWith(
    SosAlertModel value,
    $Res Function(SosAlertModel) then,
  ) = _$SosAlertModelCopyWithImpl<$Res, SosAlertModel>;
  @useResult
  $Res call({
    String alertId,
    String tourId,
    String userId,
    String userName,
    double latitude,
    double longitude,
    String status,
    String message,
    DateTime? timestamp,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class _$SosAlertModelCopyWithImpl<$Res, $Val extends SosAlertModel>
    implements $SosAlertModelCopyWith<$Res> {
  _$SosAlertModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SosAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertId = null,
    Object? tourId = null,
    Object? userId = null,
    Object? userName = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? status = null,
    Object? message = null,
    Object? timestamp = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            alertId: null == alertId
                ? _value.alertId
                : alertId // ignore: cast_nullable_to_non_nullable
                      as String,
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SosAlertModelImplCopyWith<$Res>
    implements $SosAlertModelCopyWith<$Res> {
  factory _$$SosAlertModelImplCopyWith(
    _$SosAlertModelImpl value,
    $Res Function(_$SosAlertModelImpl) then,
  ) = __$$SosAlertModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String alertId,
    String tourId,
    String userId,
    String userName,
    double latitude,
    double longitude,
    String status,
    String message,
    DateTime? timestamp,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class __$$SosAlertModelImplCopyWithImpl<$Res>
    extends _$SosAlertModelCopyWithImpl<$Res, _$SosAlertModelImpl>
    implements _$$SosAlertModelImplCopyWith<$Res> {
  __$$SosAlertModelImplCopyWithImpl(
    _$SosAlertModelImpl _value,
    $Res Function(_$SosAlertModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SosAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertId = null,
    Object? tourId = null,
    Object? userId = null,
    Object? userName = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? status = null,
    Object? message = null,
    Object? timestamp = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _$SosAlertModelImpl(
        alertId: null == alertId
            ? _value.alertId
            : alertId // ignore: cast_nullable_to_non_nullable
                  as String,
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SosAlertModelImpl extends _SosAlertModel {
  const _$SosAlertModelImpl({
    required this.alertId,
    required this.tourId,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    this.status = 'active',
    this.message = '',
    this.timestamp,
    this.resolvedAt,
  }) : super._();

  factory _$SosAlertModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SosAlertModelImplFromJson(json);

  @override
  final String alertId;
  @override
  final String tourId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String message;
  @override
  final DateTime? timestamp;
  @override
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'SosAlertModel(alertId: $alertId, tourId: $tourId, userId: $userId, userName: $userName, latitude: $latitude, longitude: $longitude, status: $status, message: $message, timestamp: $timestamp, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SosAlertModelImpl &&
            (identical(other.alertId, alertId) || other.alertId == alertId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    alertId,
    tourId,
    userId,
    userName,
    latitude,
    longitude,
    status,
    message,
    timestamp,
    resolvedAt,
  );

  /// Create a copy of SosAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SosAlertModelImplCopyWith<_$SosAlertModelImpl> get copyWith =>
      __$$SosAlertModelImplCopyWithImpl<_$SosAlertModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SosAlertModelImplToJson(this);
  }
}

abstract class _SosAlertModel extends SosAlertModel {
  const factory _SosAlertModel({
    required final String alertId,
    required final String tourId,
    required final String userId,
    required final String userName,
    required final double latitude,
    required final double longitude,
    final String status,
    final String message,
    final DateTime? timestamp,
    final DateTime? resolvedAt,
  }) = _$SosAlertModelImpl;
  const _SosAlertModel._() : super._();

  factory _SosAlertModel.fromJson(Map<String, dynamic> json) =
      _$SosAlertModelImpl.fromJson;

  @override
  String get alertId;
  @override
  String get tourId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get status;
  @override
  String get message;
  @override
  DateTime? get timestamp;
  @override
  DateTime? get resolvedAt;

  /// Create a copy of SosAlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SosAlertModelImplCopyWith<_$SosAlertModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
