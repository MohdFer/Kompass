import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/location_model.dart';
import '../data/repositories/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final tourLocationsProvider =
    StreamProvider.family<List<LocationModel>, String>((ref, tourId) {
  return ref.watch(locationRepositoryProvider).watchTourLocations(tourId);
});

/// Tracks whether location sharing is toggled on.
final locationSharingEnabledProvider = StateProvider<bool>((ref) => false);
