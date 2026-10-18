import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/models/user_model.dart';
import '../data/models/tour_model.dart';
import '../data/repositories/tour_repository.dart';

part 'tour_providers.g.dart';

@riverpod
TourRepository tourRepository(TourRepositoryRef ref) {
  return FirebaseTourRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<TourModel>> tours(ToursRef ref) {
  return ref.watch(tourRepositoryProvider).watchAllTours();
}

@riverpod
Stream<TourModel> tourDetail(TourDetailRef ref, String tourId) {
  return ref.watch(tourRepositoryProvider).watchTour(tourId);
}

@Riverpod(keepAlive: true)
class TourController extends _$TourController {
  @override
  void build() {}

  Future<String> createTour(TourModel tour) {
    return ref.read(tourRepositoryProvider).createTour(tour);
  }

  Future<void> updateTour(TourModel tour) {
    return ref.read(tourRepositoryProvider).updateTour(tour);
  }

  Future<void> deleteTour(String tourId) {
    return ref.read(tourRepositoryProvider).deleteTour(tourId);
  }

  Future<void> addParticipant(String tourId, String userId) {
    return ref.read(tourRepositoryProvider).addParticipant(tourId, userId);
  }

  Future<TourModel> requestOrJoinTour(String tourId, String userId) {
    return ref.read(tourRepositoryProvider).requestOrJoinTour(tourId, userId);
  }

  Future<TourModel> joinTourByCode(String codeInput, String userId) {
    return ref.read(tourRepositoryProvider).joinTourByCode(codeInput, userId);
  }

  Future<UserModel> inviteUserByEmail(String tourId, String email) {
    return ref.read(tourRepositoryProvider).inviteUserByEmail(tourId, email);
  }

  Future<void> revokeInvite(String tourId, String userId) {
    return ref.read(tourRepositoryProvider).revokeInvite(tourId, userId);
  }

  Future<void> respondToInvite(
    String tourId,
    String userId, {
    required bool accept,
  }) {
    return ref
        .read(tourRepositoryProvider)
        .respondToInvite(tourId, userId, accept: accept);
  }

  Future<void> respondToJoinRequest(
    String tourId,
    String userId, {
    required bool approve,
  }) {
    return ref
        .read(tourRepositoryProvider)
        .respondToJoinRequest(tourId, userId, approve: approve);
  }

  Future<void> removeParticipant(String tourId, String userId) {
    return ref.read(tourRepositoryProvider).removeParticipant(tourId, userId);
  }

  Future<void> updateTourStatus(String tourId, String status) {
    return ref.read(tourRepositoryProvider).updateTourStatus(tourId, status);
  }

  Future<void> assignGuide(String tourId, String guideId) {
    return ref.read(tourRepositoryProvider).assignGuide(tourId, guideId);
  }
}
