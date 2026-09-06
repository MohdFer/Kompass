import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sos_alert_model.freezed.dart';
part 'sos_alert_model.g.dart';

@freezed
abstract class SosAlertModel with _$SosAlertModel {
  const factory SosAlertModel({
    required String alertId,
    required String tourId,
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
    @Default('active') String status,
    @Default('') String message,
    DateTime? timestamp,
    DateTime? resolvedAt,
  }) = _SosAlertModel;

  const SosAlertModel._();

  factory SosAlertModel.fromJson(Map<String, dynamic> json) =>
      _$SosAlertModelFromJson(json);

  static SosAlertModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SosAlertModel.fromJson({
      ...data,
      'alertId': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      'resolvedAt': (data['resolvedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('alertId');
    json['timestamp'] = FieldValue.serverTimestamp();
    return json;
  }

  bool get isActive => status == 'active';
}
