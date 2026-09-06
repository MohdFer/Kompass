import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../models/itinerary_model.dart';

abstract class ItineraryRepository {
  Future<String> createItinerary(String tourId, ItineraryModel itinerary);
  Future<void> updateItinerary(String tourId, ItineraryModel itinerary);
  Future<void> deleteItinerary(String tourId, String itineraryId);
  Stream<List<ItineraryModel>> watchItineraries(String tourId);
}

class FirebaseItineraryRepository implements ItineraryRepository {
  final FirebaseFirestore _firestore;

  FirebaseItineraryRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _getItineraryCollection(String tourId) {
    return _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .collection('Itinerary');
  }

  @override
  Future<String> createItinerary(String tourId, ItineraryModel itinerary) async {
    final json = itinerary.toJson();
    json.remove('itineraryId');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['date'] = Timestamp.parse(itinerary.date.toIso8601String());

    final docRef = await _getItineraryCollection(tourId).add(json);
    return docRef.id;
  }

  @override
  Future<void> updateItinerary(String tourId, ItineraryModel itinerary) async {
    final json = itinerary.toJson();
    json.remove('itineraryId');
    json['date'] = Timestamp.parse(itinerary.date.toIso8601String());
    
    await _getItineraryCollection(tourId)
        .doc(itinerary.itineraryId)
        .update(json);
  }

  @override
  Future<void> deleteItinerary(String tourId, String itineraryId) async {
    await _getItineraryCollection(tourId).doc(itineraryId).delete();
  }

  @override
  Stream<List<ItineraryModel>> watchItineraries(String tourId) {
    return _getItineraryCollection(tourId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItineraryModel.fromFirestore(doc))
            .toList());
  }
}
