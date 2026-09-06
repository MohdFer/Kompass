/// Form field validators for the KOMPASS application.
library;

class Validators {
  Validators._();

  /// Validates an email address format.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validateEmail(String? value) => email(value);

  /// Validates password strength.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) => password(value);

  /// Validates that a required field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateName(String? value) => required(value, 'Name');

  /// Validates confirm password matches.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates tour name.
  static String? tourName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tour name is required';
    }
    if (value.trim().length < 3) {
      return 'Tour name must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Tour name must be less than 100 characters';
    }
    return null;
  }
}
