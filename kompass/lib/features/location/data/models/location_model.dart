import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

@freezed
abstract class LocationModel with _$LocationModel {
  const factory LocationModel({
    required String locationId,
    required String tourId,
    required String userId,
    required double latitude,
    required double longitude,
    DateTime? timestamp,
    @Default('') String userName,
    @Default(true) bool visibleToEveryone,
    @Default(<String>[]) List<String> visibleToUserIds,
  }) = _LocationModel;

  const LocationModel._();

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  static LocationModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final rawVisibleTo = data['visibleToUserIds'] as List<dynamic>? ?? [];
    final visibleToUserIds = rawVisibleTo.map((e) => e.toString()).toList();
    return LocationModel.fromJson({
      ...data,
      'locationId': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      'visibleToEveryone': data['visibleToEveryone'] as bool? ?? true,
      'visibleToUserIds': visibleToUserIds,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('locationId');
    json['timestamp'] = FieldValue.serverTimestamp();
    json['visibleToEveryone'] = visibleToEveryone;
    json['visibleToUserIds'] = visibleToUserIds;
    return json;
  }
}
