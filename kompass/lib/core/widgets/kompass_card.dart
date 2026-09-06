import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Styled card with subtle parchment aesthetic and warm shadow.
class KompassCard extends StatelessWidget {
  const KompassCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
          ? Border.all(color: borderColor!, width: 1.5)
          : Border.all(color: AppColors.sandDark.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
