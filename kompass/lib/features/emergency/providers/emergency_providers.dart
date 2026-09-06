import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sos_alert_model.dart';
import '../data/repositories/emergency_repository.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return EmergencyRepository();
});

final activeSOSAlertsProvider =
    StreamProvider.family<List<SosAlertModel>, String>((ref, tourId) {
  return ref.watch(emergencyRepositoryProvider).watchActiveAlerts(tourId);
});
