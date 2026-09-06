import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/itinerary_model.dart';
import '../data/repositories/itinerary_repository.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository();
});

final itinerariesProvider =
    StreamProvider.family<List<ItineraryModel>, String>((ref, tourId) {
  return ref.watch(itineraryRepositoryProvider).watchItineraries(tourId);
});
