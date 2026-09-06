import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../models/tour_model.dart';

abstract class TourRepository {
  Future<String> createTour(TourModel tour);
  Future<void> updateTour(TourModel tour);
  Future<void> deleteTour(String tourId);
  Stream<List<TourModel>> watchAllTours();
  Stream<TourModel> watchTour(String tourId);
  Future<TourModel?> getTour(String tourId);
}

class FirebaseTourRepository implements TourRepository {
  final FirebaseFirestore _firestore;

  FirebaseTourRepository(this._firestore);

  @override
  Future<String> createTour(TourModel tour) async {
    final docRef = await _firestore
        .collection(FirestoreConstants.toursCollection)
        .add(tour.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateTour(TourModel tour) async {
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tour.tourId)
        .update(tour.toFirestore());
  }

  @override
  Future<void> deleteTour(String tourId) async {
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .delete();
  }

  @override
  Stream<List<TourModel>> watchAllTours() {
    return _firestore
        .collection(FirestoreConstants.toursCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<TourModel> watchTour(String tourId) {
    return _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .snapshots()
        .map((doc) => TourModel.fromFirestore(doc));
  }

  @override
  Future<TourModel?> getTour(String tourId) async {
    final doc = await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .get();
    if (doc.exists) {
      return TourModel.fromFirestore(doc);
    }
    return null;
  }
}
