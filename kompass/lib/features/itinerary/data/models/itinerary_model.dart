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
    final data = doc.data() ?? {};
    final rawActivities = data['activities'] as List<dynamic>? ?? [];
    final activities = rawActivities.map((e) {
      if (e is Map<String, dynamic>) {
        return ActivityItem.fromJson(e);
      } else if (e is Map) {
        return ActivityItem.fromJson(Map<String, dynamic>.from(e));
      }
      return null;
    }).whereType<ActivityItem>().toList();

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ItineraryModel(
      itineraryId: doc.id,
      tourId: data['tourId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: parseDate(data['date']),
      activities: activities,
      createdAt: parseNullableDate(data['createdAt']),
    );
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
    @Default(false) bool isCompleted,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}
