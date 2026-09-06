/// Convenience extensions on BuildContext for cleaner widget code.
library;

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Access the current theme.
  ThemeData get theme => Theme.of(this);

  /// Access text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width.
  double get screenWidth => screenSize.width;

  /// Screen height.
  double get screenHeight => screenSize.height;

  /// Show a SnackBar with a message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show a loading dialog.
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Pop the loading dialog.
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }
}
