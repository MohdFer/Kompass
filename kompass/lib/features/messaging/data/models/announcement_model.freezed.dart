// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) {
  return _AnnouncementModel.fromJson(json);
}

/// @nodoc
mixin _$AnnouncementModel {
  String get announcementId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get createdByName => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this AnnouncementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnouncementModelCopyWith<AnnouncementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementModelCopyWith<$Res> {
  factory $AnnouncementModelCopyWith(
    AnnouncementModel value,
    $Res Function(AnnouncementModel) then,
  ) = _$AnnouncementModelCopyWithImpl<$Res, AnnouncementModel>;
  @useResult
  $Res call({
    String announcementId,
    String tourId,
    String title,
    String message,
    String createdBy,
    String createdByName,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$AnnouncementModelCopyWithImpl<$Res, $Val extends AnnouncementModel>
    implements $AnnouncementModelCopyWith<$Res> {
  _$AnnouncementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? announcementId = null,
    Object? tourId = null,
    Object? title = null,
    Object? message = null,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            announcementId: null == announcementId
                ? _value.announcementId
                : announcementId // ignore: cast_nullable_to_non_nullable
                      as String,
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdByName: null == createdByName
                ? _value.createdByName
                : createdByName // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnouncementModelImplCopyWith<$Res>
    implements $AnnouncementModelCopyWith<$Res> {
  factory _$$AnnouncementModelImplCopyWith(
    _$AnnouncementModelImpl value,
    $Res Function(_$AnnouncementModelImpl) then,
  ) = __$$AnnouncementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String announcementId,
    String tourId,
    String title,
    String message,
    String createdBy,
    String createdByName,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$AnnouncementModelImplCopyWithImpl<$Res>
    extends _$AnnouncementModelCopyWithImpl<$Res, _$AnnouncementModelImpl>
    implements _$$AnnouncementModelImplCopyWith<$Res> {
  __$$AnnouncementModelImplCopyWithImpl(
    _$AnnouncementModelImpl _value,
    $Res Function(_$AnnouncementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? announcementId = null,
    Object? tourId = null,
    Object? title = null,
    Object? message = null,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$AnnouncementModelImpl(
        announcementId: null == announcementId
            ? _value.announcementId
            : announcementId // ignore: cast_nullable_to_non_nullable
                  as String,
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByName: null == createdByName
            ? _value.createdByName
            : createdByName // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnnouncementModelImpl extends _AnnouncementModel {
  const _$AnnouncementModelImpl({
    required this.announcementId,
    required this.tourId,
    required this.title,
    required this.message,
    required this.createdBy,
    this.createdByName = '',
    this.timestamp,
  }) : super._();

  factory _$AnnouncementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnnouncementModelImplFromJson(json);

  @override
  final String announcementId;
  @override
  final String tourId;
  @override
  final String title;
  @override
  final String message;
  @override
  final String createdBy;
  @override
  @JsonKey()
  final String createdByName;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'AnnouncementModel(announcementId: $announcementId, tourId: $tourId, title: $title, message: $message, createdBy: $createdBy, createdByName: $createdByName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnouncementModelImpl &&
            (identical(other.announcementId, announcementId) ||
                other.announcementId == announcementId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    announcementId,
    tourId,
    title,
    message,
    createdBy,
    createdByName,
    timestamp,
  );

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnouncementModelImplCopyWith<_$AnnouncementModelImpl> get copyWith =>
      __$$AnnouncementModelImplCopyWithImpl<_$AnnouncementModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnnouncementModelImplToJson(this);
  }
}

abstract class _AnnouncementModel extends AnnouncementModel {
  const factory _AnnouncementModel({
    required final String announcementId,
    required final String tourId,
    required final String title,
    required final String message,
    required final String createdBy,
    final String createdByName,
    final DateTime? timestamp,
  }) = _$AnnouncementModelImpl;
  const _AnnouncementModel._() : super._();

  factory _AnnouncementModel.fromJson(Map<String, dynamic> json) =
      _$AnnouncementModelImpl.fromJson;

  @override
  String get announcementId;
  @override
  String get tourId;
  @override
  String get title;
  @override
  String get message;
  @override
  String get createdBy;
  @override
  String get createdByName;
  @override
  DateTime? get timestamp;

  /// Create a copy of AnnouncementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnouncementModelImplCopyWith<_$AnnouncementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
