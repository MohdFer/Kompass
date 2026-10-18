import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/message_model.dart';

class MessageRepository {
  MessageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('Messages');

  /// Send a message to a tour's chat.
  Future<String> sendMessage(String tourId, MessageModel message) async {
    try {
      final docRef = await _messagesRef(tourId).add(message.toFirestore());
      return docRef.id;
    } catch (e) {
      throw DatabaseException('Failed to send message: $e');
    }
  }

  /// Watch messages for a tour, ordered by timestamp.
  Stream<List<MessageModel>> watchMessages(String tourId) {
    return _messagesRef(tourId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(MessageModel.fromFirestore).toList());
  }
}
