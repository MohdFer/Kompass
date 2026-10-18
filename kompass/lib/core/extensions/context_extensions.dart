/// Convenience extensions on BuildContext for cleaner widget code.
library;

import 'package:flutter/material.dart';
import '../utils/app_toast.dart';

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

  /// Show a toast with a message (compat wrapper using AppToast).
  void showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      AppToast.showError(message, context: this);
    } else {
      AppToast.showSuccess(message, context: this);
    }
  }

  /// Show success toast.
  void showSuccessToast(String message, {String? title}) {
    AppToast.showSuccess(message, context: this, title: title);
  }

  /// Show error toast.
  void showErrorToast(String message, {String? title}) {
    AppToast.showError(message, context: this, title: title);
  }

  /// Show warning toast.
  void showWarningToast(String message, {String? title}) {
    AppToast.showWarning(message, context: this, title: title);
  }

  /// Show info toast.
  void showInfoToast(String message, {String? title}) {
    AppToast.showInfo(message, context: this, title: title);
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
