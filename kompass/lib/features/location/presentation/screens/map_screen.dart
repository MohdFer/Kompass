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
import '../../../tour/data/models/tour_model.dart';
import '../../../../services/permissions/app_permission_service.dart';
import '../../../../services/storage/hive_service.dart';
import '../../../auth/data/models/user_model.dart';
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
  bool _visibleToEveryone = true;
  List<String> _visibleToUserIds = <String>[];

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

    final everyoneKey = 'loc_vis_everyone_${widget.tourId}';
    final usersKey = 'loc_vis_users_${widget.tourId}';
    _visibleToEveryone = HiveService.instance.getSetting<bool>(everyoneKey) ?? true;
    final rawUsers = HiveService.instance.getSetting<List<dynamic>>(usersKey) ?? [];
    _visibleToUserIds = rawUsers.map((e) => e.toString()).toList();

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
          final turnedOn = await AppPermissionService.instance.checkAndPromptGps(
            context: context,
            title: 'Turn On Location (GPS)',
            message:
                'GPS is turned off on your device.\n\n'
                'KOMPASS requires active GPS to display and stream your live position on the map.\n\n'
                'Please turn on Location in your device settings.',
          );
          if (turnedOn && mounted) {
            _getCurrentLocation(recenter: recenter);
          }
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
      visibleToEveryone: isRallyPoint ? true : _visibleToEveryone,
      visibleToUserIds: isRallyPoint ? const [] : _visibleToUserIds,
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

    return Scaffold(
      backgroundColor: const Color(0xFF071A12),
      appBar: KompassAppBar(
        title: 'Emerald Expedition Map',
        actions: [
          IconButton(
            icon: Icon(
              _visibleToEveryone
                  ? Icons.visibility
                  : (_visibleToUserIds.isEmpty
                      ? Icons.shield_outlined
                      : Icons.group_outlined),
              color: const Color(0xFF34D399),
            ),
            tooltip: 'Location Visibility Settings',
            onPressed: () => _showVisibilitySettingsSheet(context, tour),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF34D399)),
            tooltip: 'Refresh Live Map & GPS',
            onPressed: () async {
              ref.invalidate(locationsStreamProvider);
              ref.invalidate(tourDetailProvider(widget.tourId));
              await _getCurrentLocation();
              if (context.mounted) {
                AppToast.showInfo('Map & live crew pins refreshed', context: context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_search, color: Color(0xFF34D399)),
            tooltip: 'Search & Locate Participants',
            onPressed: () {
              final allLocs = locationsAsync.valueOrNull ?? [];
              final filtered = allLocs.where((loc) => loc.tourId == widget.tourId).where((loc) {
                if (loc.userId == 'rally_point') return true;
                if (currentUser != null && loc.userId == currentUser.userId) return true;
                if (tour != null && loc.userId == tour.guideId) return true;
                if (isGuideForTour) return true;
                if (loc.visibleToEveryone) return true;
                if (currentUser != null && loc.visibleToUserIds.contains(currentUser.userId)) {
                  return true;
                }
                return false;
              }).toList();
              _showSearchParticipantsSheet(context, filtered);
            },
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
                final allTourLocations = allLocations
                    .where((loc) => loc.tourId == widget.tourId)
                    .toList();

                // Apply participant visibility filter
                final tourLocations = allTourLocations.where((loc) {
                  // 1. Rally points are always visible
                  if (loc.userId == 'rally_point') return true;
                  // 2. Current user always sees their own pin
                  if (currentUser != null && loc.userId == currentUser.userId) return true;
                  // 3. Tour guide is always visible so no participant gets lost
                  if (tour != null && loc.userId == tour.guideId) return true;
                  // 4. Tour guide has safety oversight of all tour participants
                  if (isGuideForTour) return true;
                  // 5. If broadcast visible to everyone in tour
                  if (loc.visibleToEveryone) return true;
                  // 6. If broadcast to specific user IDs and viewer is included
                  if (currentUser != null && loc.visibleToUserIds.contains(currentUser.userId)) {
                    return true;
                  }
                  return false;
                }).toList();

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
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _showVisibilitySettingsSheet(context, tour),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D3326),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _visibleToEveryone
                                              ? Icons.public_rounded
                                              : (_visibleToUserIds.isEmpty
                                                  ? Icons.shield_rounded
                                                  : Icons.group_rounded),
                                          size: 15,
                                          color: const Color(0xFF34D399),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _visibleToEveryone
                                                ? 'My GPS Visible To: Everyone in Tour'
                                                : (_visibleToUserIds.isEmpty
                                                    ? 'My GPS Visible To: Tour Guide Only'
                                                    : 'My GPS Visible To: ${_visibleToUserIds.length} Selected Member(s)'),
                                            style: const TextStyle(
                                              color: Color(0xFFECFDF5),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'Change',
                                          style: TextStyle(
                                            color: Color(0xFF34D399),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.chevron_right, size: 14, color: Color(0xFF34D399)),
                                      ],
                                    ),
                                  ),
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

  void _showVisibilitySettingsSheet(BuildContext context, TourModel? tour) {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final allUsers = ref.read(allUsersProvider).valueOrNull ?? [];

    // Filter tour members: users who are enrolled in this tour (except current user)
    final memberIds = <String>{
      if (tour != null) ...tour.participantIds,
      if (tour != null && tour.guideId.isNotEmpty) tour.guideId,
    }..remove(currentUser?.userId ?? '');

    final tourMembers = allUsers.where((u) => memberIds.contains(u.userId)).toList();
    // In case some participant IDs aren't in allUsers yet, make fallback UserModel items
    final foundIds = tourMembers.map((u) => u.userId).toSet();
    for (final id in memberIds) {
      if (!foundIds.contains(id)) {
        tourMembers.add(UserModel(
          userId: id,
          email: '',
          name: id == tour?.guideId ? 'Tour Guide' : 'Crew Member ($id)',
          role: id == tour?.guideId ? 'guide' : 'participant',
        ));
      }
    }

    int mode = _visibleToEveryone
        ? 0
        : (_visibleToUserIds.isEmpty ? 1 : 2); // 0: Everyone, 1: Guide Only, 2: Specific
    final tempSelectedUsers = Set<String>.from(_visibleToUserIds);
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF071F17),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredMembers = tourMembers.where((m) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return m.name.toLowerCase().contains(q) ||
                  m.email.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: mode == 2 ? 0.78 : 0.52,
              minChildSize: 0.38,
              maxChildSize: 0.92,
              expand: false,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share_location_rounded,
                              color: Color(0xFF34D399),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location Visibility',
                                  style: TextStyle(
                                    color: Color(0xFFECFDF5),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose who can see your GPS pin on the map',
                                  style: TextStyle(
                                    color: const Color(0xFFD1FAE5)
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Option 0: Everyone
                      _buildVisibilityOptionTile(
                        title: 'Everyone in Tour',
                        subtitle:
                            'All participants and guides can see your live position',
                        icon: Icons.public_rounded,
                        isSelected: mode == 0,
                        onTap: () => setModalState(() => mode = 0),
                      ),
                      const SizedBox(height: 8),

                      // Option 1: Guide Only
                      _buildVisibilityOptionTile(
                        title: 'Tour Guide Only',
                        subtitle:
                            'Only the tour guide can view your pin for safety & roll call',
                        icon: Icons.shield_rounded,
                        isSelected: mode == 1,
                        onTap: () => setModalState(() => mode = 1),
                      ),
                      const SizedBox(height: 8),

                      // Option 2: Specific Members
                      _buildVisibilityOptionTile(
                        title: 'Specific Crew Members',
                        subtitle:
                            'Select individual tour members who are allowed to see you',
                        icon: Icons.group_rounded,
                        isSelected: mode == 2,
                        onTap: () => setModalState(() => mode = 2),
                      ),

                      // If Specific Members mode selected, show search & member list
                      if (mode == 2) ...[
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (val) =>
                              setModalState(() => searchQuery = val.trim()),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search crew members...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF34D399),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0B3B2D),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${tempSelectedUsers.length} of ${tourMembers.length} selected',
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setModalState(() {
                                      tempSelectedUsers.addAll(
                                        tourMembers.map((m) => m.userId),
                                      );
                                    });
                                  },
                                  child: const Text(
                                    'Select All',
                                    style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setModalState(() {
                                      tempSelectedUsers.clear();
                                    });
                                  },
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: Color(0xFFA7F3D0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: filteredMembers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No members found',
                                    style: TextStyle(color: Color(0xFFA7F3D0)),
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  itemCount: filteredMembers.length,
                                  itemBuilder: (ctx, idx) {
                                    final member = filteredMembers[idx];
                                    final isSelected =
                                        tempSelectedUsers.contains(member.userId);
                                    final isGuide =
                                        member.userId == tour?.guideId;

                                    return CheckboxListTile(
                                      value: isSelected,
                                      activeColor: const Color(0xFF34D399),
                                      checkColor: Colors.black,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        member.name.isNotEmpty
                                            ? member.name
                                            : 'Crew Member',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isGuide
                                            ? '★ Tour Guide'
                                            : (member.email.isNotEmpty
                                                ? member.email
                                                : 'Participant'),
                                        style: TextStyle(
                                          color: isGuide
                                              ? AppColors.primaryGold
                                              : const Color(0xFFA7F3D0),
                                          fontSize: 12,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            tempSelectedUsers.add(member.userId);
                                          } else {
                                            tempSelectedUsers.remove(member.userId);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                      ] else
                        const Spacer(),

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34D399),
                            foregroundColor: const Color(0xFF051B11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final newEveryone = (mode == 0);
                            final newUserIds = (mode == 2)
                                ? tempSelectedUsers.toList()
                                : <String>[];

                            setState(() {
                              _visibleToEveryone = newEveryone;
                              _visibleToUserIds = newUserIds;
                            });

                            // Save to Hive for persistent state
                            final everyoneKey =
                                'loc_vis_everyone_${widget.tourId}';
                            final usersKey = 'loc_vis_users_${widget.tourId}';
                            await HiveService.instance.saveSetting(
                              everyoneKey,
                              newEveryone,
                            );
                            await HiveService.instance.saveSetting(
                              usersKey,
                              newUserIds,
                            );

                            // Update live broadcast on Firestore
                            if (_currentPosition != null && _isSharingLocation) {
                              await _broadcastLocation(_currentPosition!);
                            }

                            Navigator.pop(sheetCtx);

                            if (context.mounted) {
                              if (newEveryone) {
                                AppToast.showSuccess(
                                  'Location visible to Everyone in tour',
                                  context: context,
                                );
                              } else if (mode == 1) {
                                AppToast.showSuccess(
                                  'Location visible to Tour Guide only',
                                  context: context,
                                );
                              } else {
                                AppToast.showSuccess(
                                  'Location visible to ${newUserIds.length} selected member(s)',
                                  context: context,
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Save Visibility Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildVisibilityOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withValues(alpha: 0.18)
              : const Color(0xFF0B3B2D).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF34D399)
                : const Color(0xFF10B981).withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF34D399)
                  : const Color(0xFF6EE7B7),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF34D399)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFFD1FAE5).withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF34D399)
                  : const Color(0xFF6EE7B7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
