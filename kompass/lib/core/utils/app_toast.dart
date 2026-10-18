import 'package:flutter/material.dart';

/// Global key to display toasts reliably from anywhere in the app,
/// even across navigation transitions and after dialogs are dismissed.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Unified Toast notification system for KOMPASS.
/// Provides immediate, high-contrast, themed feedback for user actions.
class AppToast {
  AppToast._();

  /// Display a toast notification.
  static void show(
    String message, {
    ToastType type = ToastType.info,
    BuildContext? context,
    String? title,
    Duration duration = const Duration(milliseconds: 3000),
    SnackBarAction? action,
  }) {
    ScaffoldMessengerState? messenger;
    if (context != null && context.mounted) {
      try {
        messenger = ScaffoldMessenger.maybeOf(context);
      } catch (_) {}
    }
    messenger ??= rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    // Clean up raw Exception text
    var cleanMessage = message.trim();
    if (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring('Exception: '.length);
    }
    if (cleanMessage.startsWith('Bad state: ')) {
      cleanMessage = cleanMessage.substring('Bad state: '.length);
    }

    final config = _getToastConfig(type);

    // Immediately clear previous snackbars so feedback appears with zero delay
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: config.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: config.borderColor, width: 1.2),
        ),
        duration: duration,
        action: action,
        content: Row(
          children: [
            Icon(config.icon, color: config.foregroundColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title.isNotEmpty) ...[
                    Text(
                      title,
                      style: TextStyle(
                        color: config.foregroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    cleanMessage,
                    style: TextStyle(
                      color: config.foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convenience helper for success toasts (green with checkmark).
  static void showSuccess(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      message,
      type: ToastType.success,
      context: context,
      title: title,
      duration: duration ?? const Duration(milliseconds: 3000),
    );
  }

  /// Convenience helper for error / failure toasts (red with error icon).
  static void showError(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      message,
      type: ToastType.error,
      context: context,
      title: title,
      duration: duration ?? const Duration(milliseconds: 3500),
    );
  }

  /// Convenience helper for warning toasts (amber/orange with warning icon).
  static void showWarning(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      message,
      type: ToastType.warning,
      context: context,
      title: title,
      duration: duration ?? const Duration(milliseconds: 3000),
    );
  }

  /// Convenience helper for neutral/info toasts (cyan/dark with info icon).
  static void showInfo(
    String message, {
    BuildContext? context,
    String? title,
    Duration? duration,
  }) {
    show(
      message,
      type: ToastType.info,
      context: context,
      title: title,
      duration: duration ?? const Duration(milliseconds: 2800),
    );
  }

  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastConfig(
          backgroundColor: Color(0xFF132F1A),
          foregroundColor: Color(0xFF00FF66),
          borderColor: Color(0xFF00E676),
          icon: Icons.check_circle_rounded,
        );
      case ToastType.error:
        return const _ToastConfig(
          backgroundColor: Color(0xFF330C0C),
          foregroundColor: Color(0xFFFF5252),
          borderColor: Color(0xFFFF1744),
          icon: Icons.error_rounded,
        );
      case ToastType.warning:
        return const _ToastConfig(
          backgroundColor: Color(0xFF332007),
          foregroundColor: Color(0xFFFFB300),
          borderColor: Color(0xFFFF9100),
          icon: Icons.warning_amber_rounded,
        );
      case ToastType.info:
        return const _ToastConfig(
          backgroundColor: Color(0xFF0F262E),
          foregroundColor: Color(0xFF18FFFF),
          borderColor: Color(0xFF00E5FF),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _ToastConfig {
  const _ToastConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final IconData icon;
}
