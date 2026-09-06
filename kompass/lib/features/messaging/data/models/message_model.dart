import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/message_type.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String messageId,
    required String tourId,
    required String senderId,
    required String message,
    DateTime? timestamp,
    @Default('text') String type,
    @Default('') String senderName,
  }) = _MessageModel;

  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  static MessageModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MessageModel.fromJson({
      ...data,
      'messageId': doc.id,
      'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('messageId');
    json['timestamp'] = FieldValue.serverTimestamp();
    return json;
  }

  MessageType get messageType => MessageType.fromString(type);
}
