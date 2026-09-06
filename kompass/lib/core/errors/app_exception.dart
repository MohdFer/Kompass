/// Custom exception types for the KOMPASS application.
library;

/// Base exception class for all KOMPASS-specific exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, [this.stackTrace]);

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when an authentication operation fails.
class AuthException extends AppException {
  const AuthException(super.message, [super.stackTrace]);
}

/// Exception thrown when a Firestore database operation fails.
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.stackTrace]);
}

/// Exception thrown when a network operation fails.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

/// Exception thrown when a location/GPS operation fails.
class LocationException extends AppException {
  const LocationException(super.message, [super.stackTrace]);
}

/// Exception thrown when a storage (file upload/download) operation fails.
class StorageException extends AppException {
  const StorageException(super.message, [super.stackTrace]);
}

/// Exception thrown when a user lacks permission for an operation.
class PermissionException extends AppException {
  const PermissionException(super.message, [super.stackTrace]);
}
