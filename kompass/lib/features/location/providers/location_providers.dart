import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/location_repository.dart';
import '../data/models/location_model.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final locationsStreamProvider = StreamProvider<List<LocationModel>>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.streamLocations();
});
