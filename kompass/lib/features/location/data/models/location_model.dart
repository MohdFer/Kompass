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
  }) = _LocationModel;

  const LocationModel._();

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  static LocationModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return LocationModel.fromJson({
      ...data,
      'locationId': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('locationId');
    json['timestamp'] = FieldValue.serverTimestamp();
    return json;
  }
}
