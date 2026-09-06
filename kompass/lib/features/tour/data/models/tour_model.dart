import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/tour_status.dart';

part 'tour_model.freezed.dart';
part 'tour_model.g.dart';

/// Represents a tour document from the Tours collection.
@freezed
abstract class TourModel with _$TourModel {
  const factory TourModel({
    required String tourId,
    required String name,
    @Default('') String description,
    DateTime? startDate,
    DateTime? endDate,
    required String guideId,
    @Default([]) List<String> participantIds,
    @Default('Draft') String status,
    DateTime? createdAt,
  }) = _TourModel;

  const TourModel._();

  factory TourModel.fromJson(Map<String, dynamic> json) =>
      _$TourModelFromJson(json);

  static TourModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TourModel.fromJson({
      ...data,
      'tourId': doc.id,
      'startDate': (data['startDate'] as Timestamp?)?.toDate().toIso8601String(),
      'endDate': (data['endDate'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('tourId');
    if (startDate != null) json['startDate'] = Timestamp.fromDate(startDate!);
    if (endDate != null) json['endDate'] = Timestamp.fromDate(endDate!);
    json['createdAt'] = createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp();
    return json;
  }

  TourStatus get tourStatus => TourStatus.fromString(status);
  bool get isActive => tourStatus == TourStatus.active;
  bool get isCompleted => tourStatus == TourStatus.completed;
  int get participantCount => participantIds.length;
}
