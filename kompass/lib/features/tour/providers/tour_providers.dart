import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

@riverpod
class TourController extends _$TourController {
  @override
  FutureOr<void> build() {}

  Future<void> createTour(TourModel tour) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(tourRepositoryProvider).createTour(tour));
  }

  Future<void> updateTour(TourModel tour) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(tourRepositoryProvider).updateTour(tour));
  }

  Future<void> deleteTour(String tourId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(tourRepositoryProvider).deleteTour(tourId));
  }
}
