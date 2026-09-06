import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

@freezed
abstract class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String documentId,
    required String tourId,
    required String name,
    required String url,
    required String uploadedBy,
    @Default('') String fileType,
    @Default(0) int fileSizeBytes,
    DateTime? uploadedAt,
  }) = _DocumentModel;

  const DocumentModel._();

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  static DocumentModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DocumentModel.fromJson({
      ...data,
      'documentId': doc.id,
      'uploadedAt': (data['uploadedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('documentId');
    json['uploadedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  /// Returns a human-readable file size.
  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1048576) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / 1048576).toStringAsFixed(1)} MB';
  }

  bool get isPdf => fileType.toLowerCase() == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp']
      .contains(fileType.toLowerCase());
}
