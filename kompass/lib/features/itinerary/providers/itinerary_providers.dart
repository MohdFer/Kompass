import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/itinerary_model.dart';
import '../data/repositories/itinerary_repository.dart';

part 'itinerary_providers.g.dart';

@riverpod
ItineraryRepository itineraryRepository(ItineraryRepositoryRef ref) {
  return FirebaseItineraryRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<ItineraryModel>> tourItineraries(TourItinerariesRef ref, String tourId) {
  return ref.watch(itineraryRepositoryProvider).watchItineraries(tourId);
}

@riverpod
class ItineraryController extends _$ItineraryController {
  @override
  FutureOr<void> build() {}

  Future<void> createItinerary(String tourId, ItineraryModel itinerary) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(itineraryRepositoryProvider).createItinerary(tourId, itinerary));
  }

  Future<void> updateItinerary(String tourId, ItineraryModel itinerary) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(itineraryRepositoryProvider).updateItinerary(tourId, itinerary));
  }

  Future<void> deleteItinerary(String tourId, String itineraryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(itineraryRepositoryProvider).deleteItinerary(tourId, itineraryId));
  }
}
