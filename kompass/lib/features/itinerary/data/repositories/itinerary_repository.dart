import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/itinerary_model.dart';

class ItineraryRepository {
  ItineraryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _itineraryRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('Itineraries');

  Future<void> addItinerary(String tourId, ItineraryModel itinerary) async {
    try {
      await _itineraryRef(tourId).add(itinerary.toJson());
    } catch (e) {
      throw DatabaseException('Failed to add itinerary: $e');
    }
  }

  Stream<List<ItineraryModel>> watchItineraries(String tourId) {
    return _itineraryRef(tourId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ItineraryModel.fromFirestore).toList());
  }

  Future<void> updateItinerary(
    String tourId,
    ItineraryModel itinerary,
  ) async {
    try {
      await _itineraryRef(tourId)
          .doc(itinerary.itineraryId)
          .update(itinerary.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update itinerary: $e');
    }
  }

  Future<void> deleteItinerary(String tourId, String itineraryId) async {
    try {
      await _itineraryRef(tourId).doc(itineraryId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete itinerary: $e');
    }
  }
}
