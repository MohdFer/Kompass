import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@freezed
abstract class AnnouncementModel with _$AnnouncementModel {
  const factory AnnouncementModel({
    required String announcementId,
    required String tourId,
    required String title,
    required String message,
    required String createdBy,
    @Default('') String createdByName,
    DateTime? timestamp,
  }) = _AnnouncementModel;

  const AnnouncementModel._();

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);

  static AnnouncementModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AnnouncementModel.fromJson({
      ...data,
      'announcementId': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('announcementId');
    json['timestamp'] = FieldValue.serverTimestamp();
    return json;
  }
}
