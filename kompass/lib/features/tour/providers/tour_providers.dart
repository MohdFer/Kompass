import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tour_model.dart';
import '../data/repositories/tour_repository.dart';

final tourRepositoryProvider = Provider<TourRepository>((ref) {
  return TourRepository();
});

/// Watches all tours (admin view).
final allToursProvider = StreamProvider<List<TourModel>>((ref) {
  return ref.watch(tourRepositoryProvider).watchTours();
});

/// Watches tours assigned to a specific guide.
final guideToursProvider =
    StreamProvider.family<List<TourModel>, String>((ref, guideId) {
  return ref.watch(tourRepositoryProvider).watchTours(guideId: guideId);
});

/// Watches tours where a user is a participant.
final participantToursProvider =
    StreamProvider.family<List<TourModel>, String>((ref, userId) {
  return ref.watch(tourRepositoryProvider).watchParticipantTours(userId);
});

/// Fetches a single tour by ID.
final tourDetailProvider =
    FutureProvider.family<TourModel?, String>((ref, tourId) {
  return ref.watch(tourRepositoryProvider).getTour(tourId);
});
