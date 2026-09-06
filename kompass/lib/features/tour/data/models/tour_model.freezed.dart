// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TourModel _$TourModelFromJson(Map<String, dynamic> json) {
  return _TourModel.fromJson(json);
}

/// @nodoc
mixin _$TourModel {
  String get tourId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String get guideId => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TourModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourModelCopyWith<TourModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourModelCopyWith<$Res> {
  factory $TourModelCopyWith(TourModel value, $Res Function(TourModel) then) =
      _$TourModelCopyWithImpl<$Res, TourModel>;
  @useResult
  $Res call({
    String tourId,
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String guideId,
    List<String> participantIds,
    String status,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TourModelCopyWithImpl<$Res, $Val extends TourModel>
    implements $TourModelCopyWith<$Res> {
  _$TourModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tourId = null,
    Object? name = null,
    Object? description = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? guideId = null,
    Object? participantIds = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            guideId: null == guideId
                ? _value.guideId
                : guideId // ignore: cast_nullable_to_non_nullable
                      as String,
            participantIds: null == participantIds
                ? _value.participantIds
                : participantIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$TourModelImplCopyWith<$Res>
    implements $TourModelCopyWith<$Res> {
  factory _$$TourModelImplCopyWith(
    _$TourModelImpl value,
    $Res Function(_$TourModelImpl) then,
  ) = __$$TourModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tourId,
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String guideId,
    List<String> participantIds,
    String status,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TourModelImplCopyWithImpl<$Res>
    extends _$TourModelCopyWithImpl<$Res, _$TourModelImpl>
    implements _$$TourModelImplCopyWith<$Res> {
  __$$TourModelImplCopyWithImpl(
    _$TourModelImpl _value,
    $Res Function(_$TourModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tourId = null,
    Object? name = null,
    Object? description = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? guideId = null,
    Object? participantIds = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TourModelImpl(
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        guideId: null == guideId
            ? _value.guideId
            : guideId // ignore: cast_nullable_to_non_nullable
                  as String,
        participantIds: null == participantIds
            ? _value._participantIds
            : participantIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$TourModelImpl extends _TourModel {
  const _$TourModelImpl({
    required this.tourId,
    required this.name,
    this.description = '',
    this.startDate,
    this.endDate,
    required this.guideId,
    final List<String> participantIds = const [],
    this.status = 'Draft',
    this.createdAt,
  }) : _participantIds = participantIds,
       super._();

  factory _$TourModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourModelImplFromJson(json);

  @override
  final String tourId;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final String guideId;
  final List<String> _participantIds;
  @override
  @JsonKey()
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TourModel(tourId: $tourId, name: $name, description: $description, startDate: $startDate, endDate: $endDate, guideId: $guideId, participantIds: $participantIds, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourModelImpl &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.guideId, guideId) || other.guideId == guideId) &&
            const DeepCollectionEquality().equals(
              other._participantIds,
              _participantIds,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tourId,
    name,
    description,
    startDate,
    endDate,
    guideId,
    const DeepCollectionEquality().hash(_participantIds),
    status,
    createdAt,
  );

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourModelImplCopyWith<_$TourModelImpl> get copyWith =>
      __$$TourModelImplCopyWithImpl<_$TourModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourModelImplToJson(this);
  }
}

abstract class _TourModel extends TourModel {
  const factory _TourModel({
    required final String tourId,
    required final String name,
    final String description,
    final DateTime? startDate,
    final DateTime? endDate,
    required final String guideId,
    final List<String> participantIds,
    final String status,
    final DateTime? createdAt,
  }) = _$TourModelImpl;
  const _TourModel._() : super._();

  factory _TourModel.fromJson(Map<String, dynamic> json) =
      _$TourModelImpl.fromJson;

  @override
  String get tourId;
  @override
  String get name;
  @override
  String get description;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String get guideId;
  @override
  List<String> get participantIds;
  @override
  String get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourModelImplCopyWith<_$TourModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
