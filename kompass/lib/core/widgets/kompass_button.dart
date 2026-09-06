import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Primary action button with KOMPASS adventure styling.
class KompassButton extends StatelessWidget {
  const KompassButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.textOnPrimary,
          ),
        )
      : Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 10)],
            Text(label),
          ],
        );

    if (isOutlined) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: isDestructive
            ? OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 2),
              )
            : null,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: isDestructive
          ? ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            )
          : null,
        child: child,
      ),
    );
  }
}
