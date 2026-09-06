import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/tour_model.dart';
import '../models/participant_model.dart';

/// Repository handling all tour CRUD operations against Firestore.
class TourRepository {
  TourRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _toursRef =>
      _firestore.collection(FirestoreConstants.toursCollection);

  CollectionReference<Map<String, dynamic>> get _participantsRef =>
      _firestore.collection(FirestoreConstants.participantsCollection);

  /// Create a new tour.
  Future<TourModel> createTour(TourModel tour) async {
    try {
      final docRef = _toursRef.doc();
      final newTour = tour.copyWith(tourId: docRef.id);
      await docRef.set(newTour.toFirestore());
      return newTour;
    } catch (e) {
      throw DatabaseException('Failed to create tour: $e');
    }
  }

  /// Get a single tour by ID.
  Future<TourModel?> getTour(String tourId) async {
    try {
      final doc = await _toursRef.doc(tourId).get();
      if (!doc.exists) return null;
      return TourModel.fromFirestore(doc);
    } catch (e) {
      throw DatabaseException('Failed to fetch tour: $e');
    }
  }

  /// Watch all tours (optionally filtered by guideId).
  Stream<List<TourModel>> watchTours({String? guideId}) {
    Query<Map<String, dynamic>> query = _toursRef.orderBy('createdAt', descending: true);
    if (guideId != null) {
      query = query.where('guideId', isEqualTo: guideId);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map(TourModel.fromFirestore).toList());
  }

  /// Watch tours where a specific user is a participant.
  Stream<List<TourModel>> watchParticipantTours(String userId) {
    return _toursRef
        .where('participantIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(TourModel.fromFirestore).toList());
  }

  /// Update a tour.
  Future<void> updateTour(TourModel tour) async {
    try {
      await _toursRef.doc(tour.tourId).update(tour.toFirestore());
    } catch (e) {
      throw DatabaseException('Failed to update tour: $e');
    }
  }

  /// Delete a tour.
  Future<void> deleteTour(String tourId) async {
    try {
      await _toursRef.doc(tourId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete tour: $e');
    }
  }

  /// Add a participant to a tour.
  Future<void> addParticipant(String tourId, String userId) async {
    try {
      await _toursRef.doc(tourId).update({
        'participantIds': FieldValue.arrayUnion([userId]),
      });

      final participant = ParticipantModel(
        participantId: '',
        tourId: tourId,
        userId: userId,
      );
      await _participantsRef.add(participant.toFirestore());
    } catch (e) {
      throw DatabaseException('Failed to add participant: $e');
    }
  }

  /// Remove a participant from a tour.
  Future<void> removeParticipant(String tourId, String userId) async {
    try {
      await _toursRef.doc(tourId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw DatabaseException('Failed to remove participant: $e');
    }
  }
}
