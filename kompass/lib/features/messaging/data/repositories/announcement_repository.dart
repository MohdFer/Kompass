import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  AnnouncementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _announcementsRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('Announcements');

  Future<void> createAnnouncement(
    String tourId,
    AnnouncementModel announcement,
  ) async {
    try {
      await _announcementsRef(tourId).add(announcement.toFirestore());
    } catch (e) {
      throw DatabaseException('Failed to create announcement: $e');
    }
  }

  Stream<List<AnnouncementModel>> watchAnnouncements(String tourId) {
    return _announcementsRef(tourId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AnnouncementModel.fromFirestore).toList());
  }
}
