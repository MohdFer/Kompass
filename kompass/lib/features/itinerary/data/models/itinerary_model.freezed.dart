// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ItineraryModel _$ItineraryModelFromJson(Map<String, dynamic> json) {
  return _ItineraryModel.fromJson(json);
}

/// @nodoc
mixin _$ItineraryModel {
  String get itineraryId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<ActivityItem> get activities => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ItineraryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItineraryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItineraryModelCopyWith<ItineraryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItineraryModelCopyWith<$Res> {
  factory $ItineraryModelCopyWith(
    ItineraryModel value,
    $Res Function(ItineraryModel) then,
  ) = _$ItineraryModelCopyWithImpl<$Res, ItineraryModel>;
  @useResult
  $Res call({
    String itineraryId,
    String tourId,
    String title,
    String description,
    DateTime date,
    List<ActivityItem> activities,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ItineraryModelCopyWithImpl<$Res, $Val extends ItineraryModel>
    implements $ItineraryModelCopyWith<$Res> {
  _$ItineraryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItineraryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itineraryId = null,
    Object? tourId = null,
    Object? title = null,
    Object? description = null,
    Object? date = null,
    Object? activities = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            itineraryId: null == itineraryId
                ? _value.itineraryId
                : itineraryId // ignore: cast_nullable_to_non_nullable
                      as String,
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            activities: null == activities
                ? _value.activities
                : activities // ignore: cast_nullable_to_non_nullable
                      as List<ActivityItem>,
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
abstract class _$$ItineraryModelImplCopyWith<$Res>
    implements $ItineraryModelCopyWith<$Res> {
  factory _$$ItineraryModelImplCopyWith(
    _$ItineraryModelImpl value,
    $Res Function(_$ItineraryModelImpl) then,
  ) = __$$ItineraryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String itineraryId,
    String tourId,
    String title,
    String description,
    DateTime date,
    List<ActivityItem> activities,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ItineraryModelImplCopyWithImpl<$Res>
    extends _$ItineraryModelCopyWithImpl<$Res, _$ItineraryModelImpl>
    implements _$$ItineraryModelImplCopyWith<$Res> {
  __$$ItineraryModelImplCopyWithImpl(
    _$ItineraryModelImpl _value,
    $Res Function(_$ItineraryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ItineraryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itineraryId = null,
    Object? tourId = null,
    Object? title = null,
    Object? description = null,
    Object? date = null,
    Object? activities = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ItineraryModelImpl(
        itineraryId: null == itineraryId
            ? _value.itineraryId
            : itineraryId // ignore: cast_nullable_to_non_nullable
                  as String,
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        activities: null == activities
            ? _value._activities
            : activities // ignore: cast_nullable_to_non_nullable
                  as List<ActivityItem>,
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
class _$ItineraryModelImpl extends _ItineraryModel {
  const _$ItineraryModelImpl({
    required this.itineraryId,
    required this.tourId,
    required this.title,
    this.description = '',
    required this.date,
    final List<ActivityItem> activities = const [],
    this.createdAt,
  }) : _activities = activities,
       super._();

  factory _$ItineraryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryModelImplFromJson(json);

  @override
  final String itineraryId;
  @override
  final String tourId;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  final DateTime date;
  final List<ActivityItem> _activities;
  @override
  @JsonKey()
  List<ActivityItem> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ItineraryModel(itineraryId: $itineraryId, tourId: $tourId, title: $title, description: $description, date: $date, activities: $activities, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryModelImpl &&
            (identical(other.itineraryId, itineraryId) ||
                other.itineraryId == itineraryId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._activities,
              _activities,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itineraryId,
    tourId,
    title,
    description,
    date,
    const DeepCollectionEquality().hash(_activities),
    createdAt,
  );

  /// Create a copy of ItineraryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryModelImplCopyWith<_$ItineraryModelImpl> get copyWith =>
      __$$ItineraryModelImplCopyWithImpl<_$ItineraryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryModelImplToJson(this);
  }
}

abstract class _ItineraryModel extends ItineraryModel {
  const factory _ItineraryModel({
    required final String itineraryId,
    required final String tourId,
    required final String title,
    final String description,
    required final DateTime date,
    final List<ActivityItem> activities,
    final DateTime? createdAt,
  }) = _$ItineraryModelImpl;
  const _ItineraryModel._() : super._();

  factory _ItineraryModel.fromJson(Map<String, dynamic> json) =
      _$ItineraryModelImpl.fromJson;

  @override
  String get itineraryId;
  @override
  String get tourId;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get date;
  @override
  List<ActivityItem> get activities;
  @override
  DateTime? get createdAt;

  /// Create a copy of ItineraryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItineraryModelImplCopyWith<_$ItineraryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) {
  return _ActivityItem.fromJson(json);
}

/// @nodoc
mixin _$ActivityItem {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  String get locationName => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this ActivityItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityItemCopyWith<ActivityItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityItemCopyWith<$Res> {
  factory $ActivityItemCopyWith(
    ActivityItem value,
    $Res Function(ActivityItem) then,
  ) = _$ActivityItemCopyWithImpl<$Res, ActivityItem>;
  @useResult
  $Res call({
    String name,
    String description,
    String startTime,
    String endTime,
    String locationName,
    double? latitude,
    double? longitude,
    bool isCompleted,
  });
}

/// @nodoc
class _$ActivityItemCopyWithImpl<$Res, $Val extends ActivityItem>
    implements $ActivityItemCopyWith<$Res> {
  _$ActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? locationName = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            locationName: null == locationName
                ? _value.locationName
                : locationName // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityItemImplCopyWith<$Res>
    implements $ActivityItemCopyWith<$Res> {
  factory _$$ActivityItemImplCopyWith(
    _$ActivityItemImpl value,
    $Res Function(_$ActivityItemImpl) then,
  ) = __$$ActivityItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    String startTime,
    String endTime,
    String locationName,
    double? latitude,
    double? longitude,
    bool isCompleted,
  });
}

/// @nodoc
class __$$ActivityItemImplCopyWithImpl<$Res>
    extends _$ActivityItemCopyWithImpl<$Res, _$ActivityItemImpl>
    implements _$$ActivityItemImplCopyWith<$Res> {
  __$$ActivityItemImplCopyWithImpl(
    _$ActivityItemImpl _value,
    $Res Function(_$ActivityItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? locationName = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _$ActivityItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        locationName: null == locationName
            ? _value.locationName
            : locationName // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityItemImpl implements _ActivityItem {
  const _$ActivityItemImpl({
    required this.name,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.locationName = '',
    this.latitude,
    this.longitude,
    this.isCompleted = false,
  });

  factory _$ActivityItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  @JsonKey()
  final String locationName;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'ActivityItem(name: $name, description: $description, startTime: $startTime, endTime: $endTime, locationName: $locationName, latitude: $latitude, longitude: $longitude, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    startTime,
    endTime,
    locationName,
    latitude,
    longitude,
    isCompleted,
  );

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityItemImplCopyWith<_$ActivityItemImpl> get copyWith =>
      __$$ActivityItemImplCopyWithImpl<_$ActivityItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityItemImplToJson(this);
  }
}

abstract class _ActivityItem implements ActivityItem {
  const factory _ActivityItem({
    required final String name,
    final String description,
    required final String startTime,
    required final String endTime,
    final String locationName,
    final double? latitude,
    final double? longitude,
    final bool isCompleted,
  }) = _$ActivityItemImpl;

  factory _ActivityItem.fromJson(Map<String, dynamic> json) =
      _$ActivityItemImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  String get locationName;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get isCompleted;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityItemImplCopyWith<_$ActivityItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
