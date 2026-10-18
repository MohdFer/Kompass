import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_model.dart';

class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveLocation(LocationModel location) async {
    final docId = location.locationId.isNotEmpty
        ? location.locationId
        : '${location.tourId}_${location.userId}';
    await _firestore
        .collection('Locations')
        .doc(docId)
        .set(location.toFirestore(), SetOptions(merge: true));
  }

  Future<void> removeLocation(String locationId) async {
    await _firestore.collection('Locations').doc(locationId).delete();
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
