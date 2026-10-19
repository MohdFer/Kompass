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
    if (value.trim().length > 100) {
      return 'Tour name must be less than 100 characters';
    }
    return null;
  }

  /// Validates phone number format based on country code.
  /// If optional (default) and empty, returns null.
  /// For India (+91): expects a 10-digit number starting with 6, 7, 8, or 9.
  /// For other countries: expects 6 to 15 digits.
  static String? validatePhoneNumber(
    String? value, {
    String countryCode = '+91',
    bool isRequired = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Phone number is required';
      return null;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '').trim();
    if (digits.isEmpty) {
      if (isRequired) return 'Phone number is required';
      return null;
    }

    if (countryCode == '+91') {
      if (digits.length != 10) {
        return 'Please enter a valid 10-digit Indian mobile number';
      }
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
        return 'Indian mobile numbers must start with 6, 7, 8, or 9';
      }
    } else {
      if (digits.length < 6 || digits.length > 15) {
        return 'Please enter a valid phone number (6 to 15 digits)';
      }
    }
    return null;
  }
}
