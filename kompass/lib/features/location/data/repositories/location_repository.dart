import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/location_model.dart';

class LocationRepository {
  LocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locationsRef =>
      _firestore.collection(FirestoreConstants.locationsCollection);

  /// Update a user's location in Firestore.
  Future<void> updateLocation(LocationModel location) async {
    try {
      await _locationsRef
          .doc('${location.tourId}_${location.userId}')
          .set(location.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw LocationException('Failed to update location: $e');
    }
  }

  /// Watch all participant locations for a specific tour.
  Stream<List<LocationModel>> watchTourLocations(String tourId) {
    return _locationsRef
        .where('tourId', isEqualTo: tourId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(LocationModel.fromFirestore).toList());
  }
}
