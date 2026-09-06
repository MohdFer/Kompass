import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/location_providers.dart';
import '../../data/models/location_model.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({required this.tourId, super.key});
  final String tourId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }

    // Save to repository
    final location = LocationModel(
      locationId: const Uuid().v4(),
      tourId: widget.tourId,
      userId: 'current_user',
      latitude: position.latitude,
      longitude: position.longitude,
      userName: 'Current User',
    );
    ref.read(locationRepositoryProvider).saveLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsStreamProvider);

    return Scaffold(
      appBar: const KompassAppBar(title: 'Treasure Map'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : locationsAsync.when(
              data: (locations) {
                final markers = locations
                    .where((loc) => loc.tourId == widget.tourId)
                    .map((loc) => Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(loc.latitude, loc.longitude),
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.primaryGold,
                            size: 40.0,
                          ),
                        ))
                    .toList();

                if (_currentPosition != null) {
                  markers.add(
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: const Icon(
                        Icons.my_location,
                        color: AppColors.secondaryTeal,
                        size: 40.0,
                      ),
                    ),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? const LatLng(0, 0),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.kompass',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 15.0);
          } else {
            setState(() => _isLoading = true);
            _getCurrentLocation();
          }
        },
        backgroundColor: AppColors.primaryGold,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
