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
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

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
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label, maxLines: 1),
              ],
            ),
          );

    if (isOutlined) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            foregroundColor: isDestructive ? AppColors.error : null,
            side: isDestructive
                ? const BorderSide(color: AppColors.error, width: 2)
                : null,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: isDestructive ? AppColors.error : null,
        ),
        child: child,
      ),
    );
  }
}
