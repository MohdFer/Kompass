// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) {
  return _DocumentModel.fromJson(json);
}

/// @nodoc
mixin _$DocumentModel {
  String get documentId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get uploadedBy => throw _privateConstructorUsedError;
  String get fileType => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this DocumentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentModelCopyWith<DocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentModelCopyWith<$Res> {
  factory $DocumentModelCopyWith(
    DocumentModel value,
    $Res Function(DocumentModel) then,
  ) = _$DocumentModelCopyWithImpl<$Res, DocumentModel>;
  @useResult
  $Res call({
    String documentId,
    String tourId,
    String name,
    String url,
    String uploadedBy,
    String fileType,
    int fileSizeBytes,
    DateTime? uploadedAt,
  });
}

/// @nodoc
class _$DocumentModelCopyWithImpl<$Res, $Val extends DocumentModel>
    implements $DocumentModelCopyWith<$Res> {
  _$DocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentId = null,
    Object? tourId = null,
    Object? name = null,
    Object? url = null,
    Object? uploadedBy = null,
    Object? fileType = null,
    Object? fileSizeBytes = null,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            documentId: null == documentId
                ? _value.documentId
                : documentId // ignore: cast_nullable_to_non_nullable
                      as String,
            tourId: null == tourId
                ? _value.tourId
                : tourId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedBy: null == uploadedBy
                ? _value.uploadedBy
                : uploadedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            fileType: null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSizeBytes: null == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DocumentModelImplCopyWith<$Res>
    implements $DocumentModelCopyWith<$Res> {
  factory _$$DocumentModelImplCopyWith(
    _$DocumentModelImpl value,
    $Res Function(_$DocumentModelImpl) then,
  ) = __$$DocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String documentId,
    String tourId,
    String name,
    String url,
    String uploadedBy,
    String fileType,
    int fileSizeBytes,
    DateTime? uploadedAt,
  });
}

/// @nodoc
class __$$DocumentModelImplCopyWithImpl<$Res>
    extends _$DocumentModelCopyWithImpl<$Res, _$DocumentModelImpl>
    implements _$$DocumentModelImplCopyWith<$Res> {
  __$$DocumentModelImplCopyWithImpl(
    _$DocumentModelImpl _value,
    $Res Function(_$DocumentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentId = null,
    Object? tourId = null,
    Object? name = null,
    Object? url = null,
    Object? uploadedBy = null,
    Object? fileType = null,
    Object? fileSizeBytes = null,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _$DocumentModelImpl(
        documentId: null == documentId
            ? _value.documentId
            : documentId // ignore: cast_nullable_to_non_nullable
                  as String,
        tourId: null == tourId
            ? _value.tourId
            : tourId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedBy: null == uploadedBy
            ? _value.uploadedBy
            : uploadedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        fileType: null == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSizeBytes: null == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentModelImpl extends _DocumentModel {
  const _$DocumentModelImpl({
    required this.documentId,
    required this.tourId,
    required this.name,
    required this.url,
    required this.uploadedBy,
    this.fileType = '',
    this.fileSizeBytes = 0,
    this.uploadedAt,
  }) : super._();

  factory _$DocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentModelImplFromJson(json);

  @override
  final String documentId;
  @override
  final String tourId;
  @override
  final String name;
  @override
  final String url;
  @override
  final String uploadedBy;
  @override
  @JsonKey()
  final String fileType;
  @override
  @JsonKey()
  final int fileSizeBytes;
  @override
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'DocumentModel(documentId: $documentId, tourId: $tourId, name: $name, url: $url, uploadedBy: $uploadedBy, fileType: $fileType, fileSizeBytes: $fileSizeBytes, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentModelImpl &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    documentId,
    tourId,
    name,
    url,
    uploadedBy,
    fileType,
    fileSizeBytes,
    uploadedAt,
  );

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      __$$DocumentModelImplCopyWithImpl<_$DocumentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentModelImplToJson(this);
  }
}

abstract class _DocumentModel extends DocumentModel {
  const factory _DocumentModel({
    required final String documentId,
    required final String tourId,
    required final String name,
    required final String url,
    required final String uploadedBy,
    final String fileType,
    final int fileSizeBytes,
    final DateTime? uploadedAt,
  }) = _$DocumentModelImpl;
  const _DocumentModel._() : super._();

  factory _DocumentModel.fromJson(Map<String, dynamic> json) =
      _$DocumentModelImpl.fromJson;

  @override
  String get documentId;
  @override
  String get tourId;
  @override
  String get name;
  @override
  String get url;
  @override
  String get uploadedBy;
  @override
  String get fileType;
  @override
  int get fileSizeBytes;
  @override
  DateTime? get uploadedAt;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
