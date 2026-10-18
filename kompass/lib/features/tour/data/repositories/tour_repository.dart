import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/participant_model.dart';
import '../models/tour_model.dart';

abstract class TourRepository {
  Future<String> createTour(TourModel tour);
  Future<void> updateTour(TourModel tour);
  Future<void> deleteTour(String tourId);
  Stream<List<TourModel>> watchAllTours();
  Stream<TourModel> watchTour(String tourId);
  Future<TourModel?> getTour(String tourId);
  Future<void> addParticipant(String tourId, String userId);
  Future<TourModel> joinTourByCode(String codeInput, String userId);
  Future<TourModel> requestOrJoinTour(String tourId, String userId);
  Future<UserModel> inviteUserByEmail(String tourId, String email);
  Future<void> revokeInvite(String tourId, String userId);
  Future<void> respondToInvite(
    String tourId,
    String userId, {
    required bool accept,
  });
  Future<void> respondToJoinRequest(
    String tourId,
    String userId, {
    required bool approve,
  });
  Future<void> removeParticipant(String tourId, String userId);
  Future<void> updateTourStatus(String tourId, String status);
  Future<void> assignGuide(String tourId, String guideId);
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
    if (doc.exists && doc.data() != null) {
      return TourModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> addParticipant(String tourId, String userId) async {
    final docRef = _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId);
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Tour not found for ID "$tourId".');
    }

    await docRef.update({
      'participantIds': FieldValue.arrayUnion([userId]),
      'invitedUserIds': FieldValue.arrayRemove([userId]),
      'pendingRequestUserIds': FieldValue.arrayRemove([userId]),
    });

    final participant = ParticipantModel(
      participantId: '${tourId}_$userId',
      tourId: tourId,
      userId: userId,
      joinedAt: DateTime.now(),
    );
    await _firestore
        .collection(FirestoreConstants.participantsCollection)
        .doc('${tourId}_$userId')
        .set(participant.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<TourModel> requestOrJoinTour(String tourId, String userId) async {
    final tour = await getTour(tourId);
    if (tour == null) {
      throw Exception('Tour not found.');
    }
    if (tour.guideId == userId) {
      throw Exception('You are already the Tour Guide of "${tour.name}".');
    }
    if (tour.participantIds.contains(userId)) {
      throw Exception('You have already joined "${tour.name}".');
    }
    if (tour.pendingRequestUserIds.contains(userId)) {
      throw Exception(
        'Your join request for "${tour.name}" is already awaiting Tour Guide approval.',
      );
    }

    // If the user was invited by the Guide or the tour does not require join approval, admit immediately
    if (!tour.requireJoinApproval || tour.invitedUserIds.contains(userId)) {
      await addParticipant(tour.tourId, userId);
      return tour.copyWith(
        participantIds: [...tour.participantIds, userId],
      );
    }

    // Otherwise send a Join Request for the Tour Guide to accept/decline
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tour.tourId)
        .update({
      'pendingRequestUserIds': FieldValue.arrayUnion([userId]),
    });

    return tour.copyWith(
      pendingRequestUserIds: [...tour.pendingRequestUserIds, userId],
    );
  }

  @override
  Future<TourModel> joinTourByCode(String codeInput, String userId) async {
    final cleanCode = codeInput
        .replaceAll(RegExp(r'^Tour Code:\s*', caseSensitive: false), '')
        .trim();
    if (cleanCode.isEmpty) {
      throw Exception('Please enter a valid Tour Code.');
    }

    // 1. Try exact document ID lookup first
    TourModel? matchedTour = await getTour(cleanCode);

    // 2. Fallback: case-insensitive ID, short prefix (at least 4 chars), or exact tour name match
    if (matchedTour == null) {
      final snapshot = await _firestore
          .collection(FirestoreConstants.toursCollection)
          .get();
      final lowerCode = cleanCode.toLowerCase();
      for (final doc in snapshot.docs) {
        final tour = TourModel.fromFirestore(doc);
        final idLower = tour.tourId.toLowerCase();
        final nameLower = tour.name.toLowerCase();
        if (idLower == lowerCode ||
            (lowerCode.length >= 4 && idLower.startsWith(lowerCode)) ||
            nameLower == lowerCode) {
          matchedTour = tour;
          break;
        }
      }
    }

    if (matchedTour == null) {
      throw Exception('No tour found matching code "$cleanCode".');
    }

    return requestOrJoinTour(matchedTour.tourId, userId);
  }

  @override
  Future<UserModel> inviteUserByEmail(String tourId, String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw Exception('Please enter a valid email address.');
    }

    final tour = await getTour(tourId);
    if (tour == null) {
      throw Exception('Tour not found.');
    }

    // Search Users collection case-insensitively by email
    final usersSnapshot = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .get();

    UserModel? targetUser;
    for (final doc in usersSnapshot.docs) {
      final user = UserModel.fromFirestore(doc);
      if (user.email.trim().toLowerCase() == cleanEmail) {
        targetUser = user;
        break;
      }
    }

    if (targetUser == null) {
      throw Exception('No registered user found with email "$email".');
    }
    if (targetUser.userId == tour.guideId) {
      throw Exception('You are already the Tour Guide of this tour.');
    }
    if (tour.participantIds.contains(targetUser.userId)) {
      throw Exception(
        '${targetUser.name} (${targetUser.email}) is already in this tour.',
      );
    }
    if (tour.invitedUserIds.contains(targetUser.userId)) {
      throw Exception(
        'An invite has already been sent to ${targetUser.email}.',
      );
    }

    // If the user already requested to join, directly approve & admit them
    if (tour.pendingRequestUserIds.contains(targetUser.userId)) {
      await addParticipant(tourId, targetUser.userId);
      return targetUser;
    }

    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .update({
      'invitedUserIds': FieldValue.arrayUnion([targetUser.userId]),
    });

    return targetUser;
  }

  @override
  Future<void> revokeInvite(String tourId, String userId) async {
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .update({
      'invitedUserIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> respondToInvite(
    String tourId,
    String userId, {
    required bool accept,
  }) async {
    if (accept) {
      await addParticipant(tourId, userId);
    } else {
      await revokeInvite(tourId, userId);
    }
  }

  @override
  Future<void> respondToJoinRequest(
    String tourId,
    String userId, {
    required bool approve,
  }) async {
    if (approve) {
      await addParticipant(tourId, userId);
    } else {
      await _firestore
          .collection(FirestoreConstants.toursCollection)
          .doc(tourId)
          .update({
        'pendingRequestUserIds': FieldValue.arrayRemove([userId]),
      });
    }
  }

  @override
  Future<void> removeParticipant(String tourId, String userId) async {
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .update({
      'participantIds': FieldValue.arrayRemove([userId]),
    });

    try {
      await _firestore
          .collection(FirestoreConstants.participantsCollection)
          .doc('${tourId}_$userId')
          .delete();
      await _firestore
          .collection(FirestoreConstants.locationsCollection)
          .doc('${tourId}_$userId')
          .delete();
    } catch (_) {}
  }

  @override
  Future<void> updateTourStatus(String tourId, String status) async {
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .update({'status': status});
  }

  @override
  Future<void> assignGuide(String tourId, String guideId) async {
    await _firestore
        .collection(FirestoreConstants.toursCollection)
        .doc(tourId)
        .update({'guideId': guideId});
  }
}
