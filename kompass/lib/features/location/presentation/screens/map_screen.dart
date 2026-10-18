import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../data/models/location_model.dart';
import '../../providers/location_providers.dart';

enum GreenMapStyle {
  emeraldRadar(
    'Emerald Radar',
    Icons.radar,
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ),
  lushTopo(
    'Forest Topo',
    Icons.terrain,
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
  ),
  botanicalOutdoor(
    'Lush Outdoor',
    Icons.park,
    'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  );

  const GreenMapStyle(this.label, this.icon, this.urlTemplate);
  final String label;
  final IconData icon;
  final String urlTemplate;
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({required this.tourId, super.key});
  final String tourId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  bool _isSharingLocation = true;
  bool _tapToSetLocationMode = false;
  double _currentZoom = 14.5;
  GreenMapStyle _mapStyle = GreenMapStyle.emeraldRadar;
  String? _statusMessage;
  late final AnimationController _pulseController;

  // Scenic fallback coordinate if device GPS is off and no pins exist yet
  static const LatLng _defaultCenter = LatLng(12.9716, 77.5946);

  // Dark Emerald Night-Vision / Adventure Map color matrix
  static const List<double> _emeraldRadarMatrix = <double>[
    -0.25, -0.35, -0.15, 0, 18, // Red channel suppressed for deep forest tone
    -0.15, 0.55, -0.10, 0, 58,  // Green channel boosted for lush emerald glow
    -0.10, -0.15, 0.25, 0, 38,  // Blue channel balanced for teal-jade water
    0, 0, 0, 1, 0,
  ];

  // Lush Forest Topographic tint matrix
  static const List<double> _lushTopoMatrix = <double>[
    0.72, 0.05, 0.00, 0, -10,
    0.08, 1.12, 0.05, 0, 14,
    0.00, 0.08, 0.78, 0, -5,
    0, 0, 0, 1, 0,
  ];

  // Botanical Outdoor high-contrast green tint matrix
  static const List<double> _botanicalMatrix = <double>[
    0.80, 0.05, 0.00, 0, -6,
    0.06, 1.08, 0.04, 0, 10,
    0.00, 0.06, 0.85, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  ColorFilter _getMapColorFilter() {
    switch (_mapStyle) {
      case GreenMapStyle.emeraldRadar:
        return const ColorFilter.matrix(_emeraldRadarMatrix);
      case GreenMapStyle.lushTopo:
        return const ColorFilter.matrix(_lushTopoMatrix);
      case GreenMapStyle.botanicalOutdoor:
        return const ColorFilter.matrix(_botanicalMatrix);
    }
  }

  Future<void> _getCurrentLocation({bool recenter = false}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _statusMessage =
                'GPS service is disabled. Tap anywhere on the map to set your pin.';
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _statusMessage =
                  'Location permission denied. Tap pin icon to set location manually on map.';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _statusMessage =
                'Location permission permanently denied. Use manual map pin mode.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentPosition = latLng;
          _isLoading = false;
          _statusMessage = null;
        });
        if (recenter) {
          _mapController.move(latLng, _currentZoom);
        }
      }

      if (_isSharingLocation) {
        await _broadcastLocation(latLng);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Could not acquire live GPS fix. Tap the Pin tool to place your location on the map.';
        });
      }
    }
  }

  Future<void> _broadcastLocation(
    LatLng point, {
    bool isRallyPoint = false,
  }) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final userId = isRallyPoint
        ? 'rally_point'
        : (currentUser?.userId ?? 'current_user');
    final userName = isRallyPoint
        ? 'Rally Point (Guide)'
        : (currentUser?.name ?? 'Explorer');
    final docId = '${widget.tourId}_$userId';

    final location = LocationModel(
      locationId: docId,
      tourId: widget.tourId,
      userId: userId,
      latitude: point.latitude,
      longitude: point.longitude,
      userName: userName,
    );
    await ref.read(locationRepositoryProvider).saveLocation(location);
  }

  String _formatDistance(LatLng a, LatLng b) {
    const distance = Distance();
    final meters = distance.as(LengthUnit.Meter, a, b);
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsStreamProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final tour = ref.watch(tourDetailProvider(widget.tourId)).valueOrNull;
    final isGuideForTour =
        currentUser != null && tour != null && tour.guideId == currentUser.userId;
    final allLocations = locationsAsync.valueOrNull ?? [];
    final currentTourLocations = allLocations
        .where((loc) => loc.tourId == widget.tourId)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF071A12),
      appBar: KompassAppBar(
        title: 'Emerald Expedition Map',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search, color: Color(0xFF34D399)),
            tooltip: 'Search & Locate Participants',
            onPressed: () => _showSearchParticipantsSheet(context, currentTourLocations),
          ),
          IconButton(
            icon: Icon(
              _tapToSetLocationMode
                  ? Icons.edit_location_alt
                  : Icons.add_location_alt_outlined,
              color: _tapToSetLocationMode
                  ? const Color(0xFF34D399)
                  : AppColors.primaryGold,
            ),
            tooltip: _tapToSetLocationMode
                ? 'Cancel Tap-to-Pin'
                : 'Tap Map to Update Location / Rally Point',
            onPressed: () {
              setState(() {
                _tapToSetLocationMode = !_tapToSetLocationMode;
              });
              if (_tapToSetLocationMode) {
                AppToast.showInfo(
                  'Tap anywhere on the green map to set your live pin!',
                  context: context,
                );
              } else {
                AppToast.showInfo(
                  'Tap-to-pin mode disabled.',
                  context: context,
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              _isSharingLocation ? Icons.sensors : Icons.sensors_off,
              color: _isSharingLocation
                  ? const Color(0xFF34D399)
                  : AppColors.textHint,
            ),
            tooltip: _isSharingLocation
                ? 'Live GPS Sharing ON (Tap to pause)'
                : 'Live GPS Sharing PAUSED (Tap to enable)',
            onPressed: () async {
              final next = !_isSharingLocation;
              setState(() => _isSharingLocation = next);
              if (next && _currentPosition != null) {
                await _broadcastLocation(_currentPosition!);
              } else if (!next && currentUser != null) {
                await ref
                    .read(locationRepositoryProvider)
                    .removeLocation('${widget.tourId}_${currentUser.userId}');
              }
              if (context.mounted) {
                if (next) {
                  AppToast.showSuccess(
                    'Live GPS sharing enabled for this tour.',
                    context: context,
                  );
                } else {
                  AppToast.showInfo(
                    'Live GPS sharing paused.',
                    context: context,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF34D399)),
                  SizedBox(height: 16),
                  Text(
                    'Calibrating Emerald Terrain Radar...',
                    style: TextStyle(color: Color(0xFFA7F3D0)),
                  ),
                ],
              ),
            )
          : locationsAsync.when(
              data: (allLocations) {
                final tourLocations = allLocations
                    .where((loc) => loc.tourId == widget.tourId)
                    .toList();

                // Determine initial center: current GPS -> guide/crew pin -> default center
                final initialCenter = _currentPosition ??
                    (tourLocations.isNotEmpty
                        ? LatLng(
                            tourLocations.first.latitude,
                            tourLocations.first.longitude,
                          )
                        : _defaultCenter);

                // Find Tour Guide location if broadcast
                final guideLoc = tour == null
                    ? null
                    : tourLocations
                        .where((l) => l.userId == tour.guideId)
                        .firstOrNull;
                final rallyLoc = tourLocations
                    .where((l) => l.userId == 'rally_point')
                    .firstOrNull;

                final guidePoint = guideLoc != null
                    ? LatLng(guideLoc.latitude, guideLoc.longitude)
                    : (_currentPosition != null && isGuideForTour
                        ? _currentPosition
                        : null);

                // Build green safe-zone circles around Guide and Rally Point
                final circles = <CircleMarker>[
                  if (guidePoint != null)
                    CircleMarker(
                      point: guidePoint,
                      radius: 250,
                      useRadiusInMeter: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.16),
                      borderColor: const Color(0xFF34D399).withValues(alpha: 0.7),
                      borderStrokeWidth: 2,
                    ),
                  if (rallyLoc != null)
                    CircleMarker(
                      point: LatLng(rallyLoc.latitude, rallyLoc.longitude),
                      radius: 150,
                      useRadiusInMeter: true,
                      color: AppColors.primaryGold.withValues(alpha: 0.18),
                      borderColor: AppColors.primaryGold,
                      borderStrokeWidth: 2,
                    ),
                ];

                // Build emerald trail lines connecting participants to the Tour Guide
                final polylines = <Polyline>[
                  if (guidePoint != null)
                    for (final loc in tourLocations)
                      if (loc.userId != tour?.guideId)
                        Polyline(
                          points: [
                            guidePoint,
                            LatLng(loc.latitude, loc.longitude),
                          ],
                          color: const Color(0xFF34D399).withValues(alpha: 0.55),
                          strokeWidth: 2.5,
                          pattern: const StrokePattern.dotted(),
                        ),
                ];

                // Build interactive Crew & Guide markers
                final markers = <Marker>[
                  for (final loc in tourLocations)
                    if (loc.userId != currentUser?.userId)
                      Marker(
                        width: 130,
                        height: 82,
                        point: LatLng(loc.latitude, loc.longitude),
                        child: _buildCrewMarker(
                          name: loc.userName.isNotEmpty
                              ? loc.userName
                              : 'Explorer',
                          isGuide: loc.userId == tour?.guideId,
                          isRally: loc.userId == 'rally_point',
                          distanceText: _currentPosition != null
                              ? _formatDistance(
                                  _currentPosition!,
                                  LatLng(loc.latitude, loc.longitude),
                                )
                              : null,
                        ),
                      ),
                  if (_currentPosition != null)
                    Marker(
                      width: 130,
                      height: 86,
                      point: _currentPosition!,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) => _buildCurrentUserMarker(
                          name: currentUser != null
                              ? '${currentUser.name} (You)'
                              : 'You',
                          isGuide: isGuideForTour,
                          pulseValue: _pulseController.value,
                        ),
                      ),
                    ),
                ];

                return Stack(
                  children: [
                    // ── Green-Themed Interactive Map ──
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: _currentZoom,
                        onPositionChanged: (pos, _) {
                          if (pos.zoom != _currentZoom) {
                            _currentZoom = pos.zoom;
                          }
                        },
                        onTap: (tapPosition, latLng) async {
                          if (_tapToSetLocationMode) {
                            setState(() {
                              _currentPosition = latLng;
                              _tapToSetLocationMode = false;
                              _statusMessage = null;
                            });
                            await _broadcastLocation(latLng);
                            if (context.mounted) {
                              AppToast.showSuccess(
                                'Updated your live pin to (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})',
                                context: context,
                              );
                            }
                          }
                        },
                        onLongPress: (tapPosition, latLng) async {
                          if (isGuideForTour) {
                            await _broadcastLocation(
                              latLng,
                              isRallyPoint: true,
                            );
                            if (context.mounted) {
                              AppToast.showSuccess(
                                'Tour Guide Rally Point placed on map!',
                                context: context,
                              );
                            }
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: _mapStyle.urlTemplate,
                          userAgentPackageName: 'com.kompass.app',
                          tileBuilder: (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: _getMapColorFilter(),
                              child: tileWidget,
                            );
                          },
                        ),
                        CircleLayer(circles: circles),
                        PolylineLayer(polylines: polylines),
                        MarkerLayer(markers: markers),
                      ],
                    ),

                    // ── Top Green Map Style Switcher & Radar Status HUD ──
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF071F17)
                                  .withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.5),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isSharingLocation
                                            ? const Color(0xFF34D399)
                                            : AppColors.warning,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF34D399)
                                                .withValues(alpha: 0.7),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${tourLocations.length} Active on Radar • ${isGuideForTour ? "Long-press map to set Rally Point" : "Green Zone = 250m Guide Radius"}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: const Color(0xFFD1FAE5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: GreenMapStyle.values.map((style) {
                                      final isSelected = _mapStyle == style;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ChoiceChip(
                                          avatar: Icon(
                                            style.icon,
                                            size: 16,
                                            color: isSelected
                                                ? const Color(0xFF06281E)
                                                : const Color(0xFF6EE7B7),
                                          ),
                                          label: Text(style.label),
                                          selected: isSelected,
                                          selectedColor:
                                              const Color(0xFF34D399),
                                          backgroundColor:
                                              const Color(0xFF0D3326),
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF06281E)
                                                : const Color(0xFFD1FAE5),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                          onSelected: (_) {
                                            setState(() => _mapStyle = style);
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_statusMessage != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B)
                                    .withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF6EE7B7),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _statusMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFFECFDF5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _tapToSetLocationMode = true;
                                        _statusMessage =
                                            'Tap anywhere on the map now to place your pin.';
                                      });
                                    },
                                    child: const Text(
                                      'PIN NOW',
                                      style: TextStyle(
                                        color: Color(0xFF34D399),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Right Zoom & Compass Controls ──
                    Positioned(
                      right: 14,
                      bottom: 100,
                      child: Column(
                        children: [
                          _buildMapControlBtn(
                            icon: Icons.add,
                            tooltip: 'Zoom In',
                            onTap: () {
                              _currentZoom = (_currentZoom + 1).clamp(3.0, 19.0);
                              _mapController.move(
                                _mapController.camera.center,
                                _currentZoom,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildMapControlBtn(
                            icon: Icons.remove,
                            tooltip: 'Zoom Out',
                            onTap: () {
                              _currentZoom = (_currentZoom - 1).clamp(3.0, 19.0);
                              _mapController.move(
                                _mapController.camera.center,
                                _currentZoom,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildMapControlBtn(
                            icon: Icons.my_location,
                            tooltip: 'My GPS Location',
                            isPrimary: true,
                            onTap: () {
                              if (_currentPosition != null) {
                                _mapController.move(_currentPosition!, 15.5);
                              } else {
                                _getCurrentLocation(recenter: true);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── Bottom Crew Radar Strip (Tap any member to jump to their pin) ──
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF071F17).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.5),
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_currentPosition != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ActionChip(
                                    avatar: const Icon(
                                      Icons.my_location,
                                      size: 16,
                                      color: Color(0xFF34D399),
                                    ),
                                    label: const Text('You'),
                                    backgroundColor: const Color(0xFF0D3326),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFFECFDF5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onPressed: () => _mapController.move(
                                      _currentPosition!,
                                      16.0,
                                    ),
                                  ),
                                ),
                              for (final loc in tourLocations)
                                if (loc.userId != currentUser?.userId)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ActionChip(
                                      avatar: Icon(
                                        loc.userId == tour?.guideId
                                            ? Icons.stars
                                            : (loc.userId == 'rally_point'
                                                ? Icons.flag
                                                : Icons.person_pin_circle),
                                        size: 16,
                                        color: loc.userId == tour?.guideId ||
                                                loc.userId == 'rally_point'
                                            ? AppColors.primaryGold
                                            : const Color(0xFF34D399),
                                      ),
                                      label: Text(
                                        loc.userName.isNotEmpty
                                            ? loc.userName
                                            : 'Explorer',
                                      ),
                                      backgroundColor: const Color(0xFF0D3326),
                                      labelStyle: const TextStyle(
                                        color: Color(0xFFECFDF5),
                                      ),
                                      onPressed: () => _mapController.move(
                                        LatLng(loc.latitude, loc.longitude),
                                        16.0,
                                      ),
                                    ),
                                  ),
                              if (tourLocations.isEmpty &&
                                  _currentPosition == null)
                                const Text(
                                  'No active pins yet — tap the Pin icon above to place your marker!',
                                  style: TextStyle(
                                    color: Color(0xFFA7F3D0),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF34D399)),
              ),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? const Color(0xFF10B981) : const Color(0xFF071F17),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF34D399).withValues(alpha: 0.6),
        ),
      ),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: isPrimary
                  ? const Color(0xFF051B11)
                  : const Color(0xFF6EE7B7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserMarker({
    required String name,
    required bool isGuide,
    required double pulseValue,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF06281E).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isGuide ? AppColors.primaryGold : const Color(0xFF34D399),
              width: 1.5,
            ),
          ),
          child: Text(
            isGuide ? '★ $name' : name,
            style: const TextStyle(
              color: Color(0xFFECFDF5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 28 + (pulseValue * 18),
              height: 28 + (pulseValue * 18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981)
                    .withValues(alpha: 0.45 * (1 - pulseValue)),
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGuide ? AppColors.primaryGold : const Color(0xFF10B981),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                isGuide ? Icons.explore : Icons.navigation,
                size: 18,
                color: const Color(0xFF051B11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCrewMarker({
    required String name,
    required bool isGuide,
    required bool isRally,
    String? distanceText,
  }) {
    final badgeColor = isRally || isGuide
        ? AppColors.primaryGold
        : const Color(0xFF34D399);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF06281E).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: badgeColor, width: 1.2),
          ),
          child: Text(
            distanceText != null ? '$name ($distanceText)' : name,
            style: const TextStyle(
              color: Color(0xFFECFDF5),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: badgeColor,
            border: Border.all(color: const Color(0xFF06281E), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 6),
            ],
          ),
          child: Icon(
            isRally
                ? Icons.flag
                : (isGuide ? Icons.stars : Icons.person_pin_circle),
            size: 18,
            color: const Color(0xFF051B11),
          ),
        ),
      ],
    );
  }

  void _showSearchParticipantsSheet(
    BuildContext context,
    List<LocationModel> tourLocations,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06281E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = tourLocations.where((l) {
              if (query.isEmpty) return true;
              return l.userName.toLowerCase().contains(query);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radar, color: Color(0xFF34D399)),
                      const SizedBox(width: 8),
                      Text(
                        'Locate Participants (${tourLocations.length})',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: const Color(0xFF34D399),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) => setSheetState(() => query = val.trim().toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search crew member by name...',
                      hintStyle: const TextStyle(color: Color(0xFFA7F3D0)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF34D399)),
                      filled: true,
                      fillColor: const Color(0xFF0B3B2D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          query.isEmpty
                              ? 'No crew GPS positions broadcasting yet.'
                              : 'No participant matches "$query"',
                          style: const TextStyle(color: Color(0xFFA7F3D0)),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final loc = filtered[idx];
                          final isRally = loc.userId == 'rally_point';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isRally
                                  ? AppColors.primaryGold
                                  : const Color(0xFF34D399),
                              child: Icon(
                                isRally ? Icons.flag : Icons.person_pin_circle,
                                color: Colors.black,
                              ),
                            ),
                            title: Text(
                              loc.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'GPS: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: Color(0xFFA7F3D0),
                                fontSize: 12,
                              ),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF34D399),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.pop(sheetCtx);
                                _mapController.move(
                                  LatLng(loc.latitude, loc.longitude),
                                  16.5,
                                );
                                AppToast.showInfo('Centered map on ${loc.userName}');
                              },
                              child: const Text('Center'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
