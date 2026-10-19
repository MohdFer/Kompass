import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Minimalist geometric compass brand mark used across Splash, Auth, and App headers.
/// Supports an optional curvy bordered badge container ([hasCurvedBorder]).
class KompassLogoMark extends StatelessWidget {
  const KompassLogoMark({
    this.size = 64.0,
    this.hasCurvedBorder = false,
    this.borderRadius,
    super.key,
  });

  final double size;
  final bool hasCurvedBorder;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: hasCurvedBorder ? size * 0.68 : size,
      height: hasCurvedBorder ? size * 0.68 : size,
      child: const CustomPaint(
        painter: _MinimalCompassPainter(
          primaryColor: AppColors.primaryNeon,
          secondaryColor: Colors.white,
        ),
      ),
    );

    if (!hasCurvedBorder) {
      return mark;
    }

    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF060606),
        borderRadius: effectiveRadius,
        border: Border.all(
          color: AppColors.primaryNeon.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNeon.withValues(alpha: 0.14),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: mark),
    );
  }
}

class _MinimalCompassPainter extends CustomPainter {
  const _MinimalCompassPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Subtle outer ring
    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius - (size.width * 0.03), ringPaint);

    // North needle (accent color)
    final northPath = Path()
      ..moveTo(center.dx, center.dy - (radius * 0.72))
      ..lineTo(center.dx + (radius * 0.20), center.dy)
      ..lineTo(center.dx - (radius * 0.20), center.dy)
      ..close();

    final northPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // South needle (clean white)
    final southPath = Path()
      ..moveTo(center.dx, center.dy + (radius * 0.72))
      ..lineTo(center.dx + (radius * 0.20), center.dy)
      ..lineTo(center.dx - (radius * 0.20), center.dy)
      ..close();

    final southPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Rotate 28 degrees (0.48 rad) for dynamic compass orientation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.48);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawPath(northPath, northPaint);
    canvas.drawPath(southPath, southPaint);

    // Center pivot dot
    final pivotPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, size.width * 0.048, pivotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MinimalCompassPainter oldDelegate) => false;
}
