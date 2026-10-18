import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/enums/tour_status.dart';
import '../../../core/utils/app_toast.dart';
import '../../../services/storage/hive_service.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../../tour/data/models/tour_model.dart';
import '../../tour/providers/tour_providers.dart';
import '../data/models/location_model.dart';
import '../data/repositories/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final locationsStreamProvider = StreamProvider<List<LocationModel>>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.streamLocations();
});

/// Notifier that informs the app whether GPS is required (active tour + streaming consent) but currently turned off.
class GpsStatusNotifier extends ChangeNotifier {
  bool _isGpsDisabledWhenRequired = false;
  bool get isGpsDisabledWhenRequired => _isGpsDisabledWhenRequired;

  void setGpsDisabled(bool value) {
    if (_isGpsDisabledWhenRequired != value) {
      _isGpsDisabledWhenRequired = value;
      notifyListeners();
    }
  }
}

final gpsStatusProvider = ChangeNotifierProvider<GpsStatusNotifier>((ref) {
  return TourLocationTrackerService.instance.gpsNotifier;
});

/// Service that coordinates automatic periodic location tracking for enrolled users
/// during the active tour timeframe when location streaming consent is granted.
class TourLocationTrackerService {
  TourLocationTrackerService._();
  static final instance = TourLocationTrackerService._();

  final GpsStatusNotifier gpsNotifier = GpsStatusNotifier();
  DateTime? _lastGpsToastTime;

  Timer? _trackingTimer;
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Syncs active tracking: if user is enrolled in an active tour whose current time
  /// is within tour dates and the user permits location streaming, periodic tracking is initiated.
  void syncActiveTourTracking({
    required UserModel? user,
    required List<TourModel> allTours,
    required LocationRepository repository,
  }) {
    if (user == null) {
      _stopTracking();
      gpsNotifier.setGpsDisabled(false);
      return;
    }

    // 1. Find tours where user is enrolled as participant or guide
    final enrolledTours = allTours.where((t) {
      return t.guideId == user.userId || t.participantIds.contains(user.userId);
    }).toList();

    // 2. Filter tours that are currently active and within scheduled dates
    final now = DateTime.now();
    final activeTours = enrolledTours.where((t) {
      if (t.status != TourStatus.active.label && !t.isActive) return false;
      if (t.startDate != null && now.isBefore(t.startDate!.subtract(const Duration(hours: 1)))) {
        return false;
      }
      if (t.endDate != null && now.isAfter(t.endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();

    if (activeTours.isEmpty) {
      _stopTracking();
      gpsNotifier.setGpsDisabled(false);
      return;
    }

    // 3. Verify user consent: Guides always stream; participants must have location_sharing enabled
    final isGuide = user.role == 'guide' || activeTours.any((t) => t.guideId == user.userId);
    final hasPermittedStreaming = isGuide || HiveService.instance.isLocationSharingEnabled;

    if (!hasPermittedStreaming) {
      _stopTracking();
      gpsNotifier.setGpsDisabled(false);
      return;
    }

    // 4. Start or maintain active periodic tracking
    if (_trackingTimer == null || !_trackingTimer!.isActive) {
      _isTracking = true;
      _triggerSingleLocationUpdate(user, activeTours, repository);
      _trackingTimer = Timer.periodic(const Duration(seconds: 45), (_) {
        _triggerSingleLocationUpdate(user, activeTours, repository);
      });
      debugPrint('TourLocationTrackerService: Started active tour tracking for ${activeTours.length} tour(s).');
    }
  }

  Future<void> _triggerSingleLocationUpdate(
    UserModel user,
    List<TourModel> activeTours,
    LocationRepository repository,
  ) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        gpsNotifier.setGpsDisabled(true);

        // Notify user via warning toast (throttled every 3 minutes)
        final now = DateTime.now();
        if (_lastGpsToastTime == null || now.difference(_lastGpsToastTime!) > const Duration(minutes: 3)) {
          _lastGpsToastTime = now;
          AppToast.showWarning('GPS is turned off. Location sharing is active for your tour. Please turn on Location in Settings.');
        }
        return;
      }

      gpsNotifier.setGpsDisabled(false);

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      for (final tour in activeTours) {
        final everyoneKey = 'loc_vis_everyone_${tour.tourId}';
        final usersKey = 'loc_vis_users_${tour.tourId}';
        final visibleToEveryone = HiveService.instance.getSetting<bool>(everyoneKey) ?? true;
        final rawUsers = HiveService.instance.getSetting<List<dynamic>>(usersKey) ?? [];
        final visibleToUserIds = rawUsers.map((e) => e.toString()).toList();

        final loc = LocationModel(
          locationId: '${tour.tourId}_${user.userId}',
          tourId: tour.tourId,
          userId: user.userId,
          latitude: position.latitude,
          longitude: position.longitude,
          userName: user.name,
          visibleToEveryone: visibleToEveryone,
          visibleToUserIds: visibleToUserIds,
        );
        await repository.saveLocation(loc);
      }
    } catch (e) {
      debugPrint('TourLocationTrackerService update error: $e');
    }
  }

  void _stopTracking() {
    if (_trackingTimer != null) {
      _trackingTimer?.cancel();
      _trackingTimer = null;
    }
    _isTracking = false;
  }
}

/// Provider that coordinates automated in-tour location tracking
final tourLocationTrackerCoordinatorProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final allTours = ref.watch(toursProvider).valueOrNull ?? [];
  final repo = ref.watch(locationRepositoryProvider);

  TourLocationTrackerService.instance.syncActiveTourTracking(
    user: user,
    allTours: allTours,
    repository: repo,
  );
});
