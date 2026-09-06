import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'itinerary_model.freezed.dart';
part 'itinerary_model.g.dart';

@freezed
abstract class ItineraryModel with _$ItineraryModel {
  const factory ItineraryModel({
    required String itineraryId,
    required String tourId,
    required String title,
    @Default('') String description,
    required DateTime date,
    @Default([]) List<ActivityItem> activities,
    DateTime? createdAt,
  }) = _ItineraryModel;

  const ItineraryModel._();

  factory ItineraryModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryModelFromJson(json);

  static ItineraryModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ItineraryModel.fromJson({
      ...data,
      'itineraryId': doc.id,
      'date': (data['date'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

@freezed
abstract class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    required String name,
    @Default('') String description,
    required String startTime,
    required String endTime,
    @Default('') String locationName,
    double? latitude,
    double? longitude,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}
