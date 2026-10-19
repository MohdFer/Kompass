import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_logo.dart';
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
                const KompassLogoMark(size: 72, hasCurvedBorder: true),
                const SizedBox(height: 20),
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
