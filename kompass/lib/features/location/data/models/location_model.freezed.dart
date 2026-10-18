// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  return _LocationModel.fromJson(json);
}

/// @nodoc
mixin _$LocationModel {
  String get locationId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  bool get visibleToEveryone => throw _privateConstructorUsedError;
  List<String> get visibleToUserIds => throw _privateConstructorUsedError;

  /// Serializes this LocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationModelCopyWith<LocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
    LocationModel value,
    $Res Function(LocationModel) then,
  ) = _$LocationModelCopyWithImpl<$Res, LocationModel>;
  @useResult
  $Res call({
    String locationId,
    String tourId,
    String userId,
    double latitude,
    double longitude,
    DateTime? timestamp,
    String userName,
    bool visibleToEveryone,
    List<String> visibleToUserIds,
  });
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res, $Val extends LocationModel>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationId = null,
    Object? tourId = null,
    Object? userId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = freezed,
    Object? userName = null,
    Object? visibleToEveryone = null,
    Object? visibleToUserIds = null,
  }) {
    return _then(
      _value.copyWith(
            locationId: null == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                      as String,
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            visibleToEveryone: null == visibleToEveryone
                ? _value.visibleToEveryone
                : visibleToEveryone // ignore: cast_nullable_to_non_nullable
                      as bool,
            visibleToUserIds: null == visibleToUserIds
                ? _value.visibleToUserIds
                : visibleToUserIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationModelImplCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory _$$LocationModelImplCopyWith(
    _$LocationModelImpl value,
    $Res Function(_$LocationModelImpl) then,
  ) = __$$LocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String locationId,
    String tourId,
    String userId,
    double latitude,
    double longitude,
    DateTime? timestamp,
    String userName,
    bool visibleToEveryone,
    List<String> visibleToUserIds,
  });
}

/// @nodoc
class __$$LocationModelImplCopyWithImpl<$Res>
    extends _$LocationModelCopyWithImpl<$Res, _$LocationModelImpl>
    implements _$$LocationModelImplCopyWith<$Res> {
  __$$LocationModelImplCopyWithImpl(
    _$LocationModelImpl _value,
    $Res Function(_$LocationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationId = null,
    Object? tourId = null,
    Object? userId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = freezed,
    Object? userName = null,
    Object? visibleToEveryone = null,
    Object? visibleToUserIds = null,
  }) {
    return _then(
      _$LocationModelImpl(
        locationId: null == locationId
            ? _value.locationId
            : locationId // ignore: cast_nullable_to_non_nullable
                  as String,
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        visibleToEveryone: null == visibleToEveryone
            ? _value.visibleToEveryone
            : visibleToEveryone // ignore: cast_nullable_to_non_nullable
                  as bool,
        visibleToUserIds: null == visibleToUserIds
            ? _value.visibleToUserIds
            : visibleToUserIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationModelImpl extends _LocationModel {
  const _$LocationModelImpl({
    required this.locationId,
    required this.tourId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.userName = '',
    this.visibleToEveryone = true,
    final List<String> visibleToUserIds = const <String>[],
  }) : _visibleToUserIds = visibleToUserIds,
       super._();

  factory _$LocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationModelImplFromJson(json);

  @override
  final String locationId;
  @override
  final String tourId;
  @override
  final String userId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime? timestamp;
  @override
  @JsonKey()
  final String userName;
  @override
  @JsonKey()
  final bool visibleToEveryone;
  final List<String> _visibleToUserIds;
  @override
  @JsonKey()
  List<String> get visibleToUserIds {
    if (_visibleToUserIds is EqualUnmodifiableListView) return _visibleToUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleToUserIds);
  }

  @override
  String toString() {
    return 'LocationModel(locationId: $locationId, tourId: $tourId, userId: $userId, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, userName: $userName, visibleToEveryone: $visibleToEveryone, visibleToUserIds: $visibleToUserIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationModelImpl &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.visibleToEveryone, visibleToEveryone) ||
                other.visibleToEveryone == visibleToEveryone) &&
            const DeepCollectionEquality()
                .equals(other._visibleToUserIds, _visibleToUserIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    locationId,
    tourId,
    userId,
    latitude,
    longitude,
    timestamp,
    userName,
    visibleToEveryone,
    const DeepCollectionEquality().hash(_visibleToUserIds),
  );

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      __$$LocationModelImplCopyWithImpl<_$LocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationModelImplToJson(this);
  }
}

abstract class _LocationModel extends LocationModel {
  const factory _LocationModel({
    required final String locationId,
    required final String tourId,
    required final String userId,
    required final double latitude,
    required final double longitude,
    final DateTime? timestamp,
    final String userName,
    final bool visibleToEveryone,
    final List<String> visibleToUserIds,
  }) = _$LocationModelImpl;
  const _LocationModel._() : super._();

  factory _LocationModel.fromJson(Map<String, dynamic> json) =
      _$LocationModelImpl.fromJson;

  @override
  String get locationId;
  @override
  String get tourId;
  @override
  String get userId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime? get timestamp;
  @override
  String get userName;
  @override
  bool get visibleToEveryone;
  @override
  List<String> get visibleToUserIds;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
