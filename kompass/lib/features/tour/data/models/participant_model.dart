import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/participant_status.dart';

part 'participant_model.freezed.dart';
part 'participant_model.g.dart';

@freezed
abstract class ParticipantModel with _$ParticipantModel {
  const factory ParticipantModel({
    required String participantId,
    required String tourId,
    required String userId,
    @Default('Participant') String role,
    @Default('Active') String status,
    DateTime? joinedAt,
  }) = _ParticipantModel;

  const ParticipantModel._();

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantModelFromJson(json);

  static ParticipantModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ParticipantModel.fromJson({
      ...data,
      'participantId': doc.id,
      'joinedAt': (data['joinedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('participantId');
    json['joinedAt'] = joinedAt != null
        ? Timestamp.fromDate(joinedAt!)
        : FieldValue.serverTimestamp();
    return json;
  }

  ParticipantStatus get participantStatus =>
      ParticipantStatus.fromString(status);
}
