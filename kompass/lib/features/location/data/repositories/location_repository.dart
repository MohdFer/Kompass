import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_model.dart';

class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveLocation(LocationModel location) async {
    await _firestore
        .collection('Locations')
        .doc(location.locationId)
        .set(location.toFirestore());
  }

  Stream<List<LocationModel>> streamLocations() {
    return _firestore.collection('Locations').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LocationModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<List<LocationModel>> getLocations() async {
    final snapshot = await _firestore.collection('Locations').get();
    return snapshot.docs
        .map((doc) => LocationModel.fromFirestore(doc))
        .toList();
  }
}
