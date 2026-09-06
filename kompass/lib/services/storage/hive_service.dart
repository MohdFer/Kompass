import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing local Hive storage boxes.
class HiveService {
  HiveService._();
  static final instance = HiveService._();

  static const String _userBoxName = 'user_cache';
  static const String _settingsBoxName = 'app_settings';

  late Box<dynamic> _userBox;
  late Box<dynamic> _settingsBox;

  /// Initialize Hive and open required boxes.
  Future<void> initialize() async {
    _userBox = await Hive.openBox(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  /// Cache user profile data locally.
  Future<void> cacheUserProfile(Map<String, dynamic> userData) async {
    await _userBox.put('current_user', userData);
  }

  /// Retrieve cached user profile.
  Map<String, dynamic>? getCachedUserProfile() {
    return _userBox.get('current_user') as Map<String, dynamic>?;
  }

  /// Save a setting.
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting.
  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  /// Check if location sharing consent is granted.
  bool get isLocationSharingEnabled =>
      _settingsBox.get('location_sharing', defaultValue: false) as bool;

  /// Set location sharing consent.
  Future<void> setLocationSharing({required bool enabled}) async {
    await _settingsBox.put('location_sharing', enabled);
  }

  /// Clear all cached data (on logout).
  Future<void> clearAll() async {
    await _userBox.clear();
    // Keep settings
  }
}
