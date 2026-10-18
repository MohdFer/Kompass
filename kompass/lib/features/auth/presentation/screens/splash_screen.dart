import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routing/route_names.dart';
import '../../providers/auth_providers.dart';

/// Tracks whether the initial splash animation has completed.
final splashCompletedProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    ref.read(splashCompletedProvider.notifier).state = true;

    final authUser = ref.read(authStateChangesProvider).valueOrNull;
    if (authUser == null) {
      context.goNamed(RouteNames.login);
      return;
    }

    final currentUser = await ref.read(currentUserProvider.future);
    if (!mounted) return;
    if (currentUser != null) {
      if (currentUser.userRole == UserRole.admin) {
        context.goNamed(RouteNames.adminDashboard);
      } else {
        context.goNamed(RouteNames.participantDashboard);
      }
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimalist geometric compass mark
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CustomPaint(
                    painter: _MinimalCompassPainter(
                      primaryColor: AppColors.primaryNeon,
                      secondaryColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Clean, iconic wordmark
                Text(
                  'KOMPASS',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 7.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Crisp, minimal geometric compass emblem (no raster artifacts or AI glow).
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
      ..strokeWidth = 2.2
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius - 2, ringPaint);

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

    // Save canvas and rotate slightly (28 degrees) for an iconic dynamic compass needle
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
    canvas.drawCircle(center, 3.0, pivotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MinimalCompassPainter oldDelegate) => false;
}
