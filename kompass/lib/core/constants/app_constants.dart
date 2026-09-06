/// App-wide constants for the KOMPASS application.
library;

/// Application metadata constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'KOMPASS';
  static const String appTagline = 'Navigate Together, Explore Forever';
  static const String appVersion = '1.0.0';

  // GPS Polling Intervals
  static const int activePollingIntervalMs = 5000;
  static const int stationaryPollingIntervalMs = 60000;
  static const int locationDistanceFilterMeters = 10;

  // Attendance
  static const int qrCodeRefreshIntervalSeconds = 30;

  // Messaging
  static const int maxMessageLength = 1000;
  static const int messagePageSize = 50;

  // Tour
  static const int maxParticipantsPerTour = 500;
  static const int maxActiveTours = 100;
}
