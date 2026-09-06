import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/sos_alert_model.dart';

class EmergencyRepository {
  EmergencyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _alertsRef(String tourId) =>
      _firestore
          .collection('Tours')
          .doc(tourId)
          .collection('SOSAlerts');

  /// Trigger an SOS alert.
  Future<void> triggerSOS(String tourId, SosAlertModel alert) async {
    try {
      await _alertsRef(tourId).add(alert.toFirestore());
    } catch (e) {
      throw DatabaseException('Failed to trigger SOS: $e');
    }
  }

  /// Resolve an SOS alert.
  Future<void> resolveSOS(String tourId, String alertId) async {
    try {
      await _alertsRef(tourId).doc(alertId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to resolve SOS: $e');
    }
  }

  /// Watch active SOS alerts for a tour.
  Stream<List<SosAlertModel>> watchActiveAlerts(String tourId) {
    return _alertsRef(tourId)
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(SosAlertModel.fromFirestore).toList());
  }

  /// Watch all SOS alerts for a tour (active and resolved).
  Stream<List<SosAlertModel>> watchAllAlerts(String tourId) {
    return _alertsRef(tourId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(SosAlertModel.fromFirestore).toList());
  }
}
