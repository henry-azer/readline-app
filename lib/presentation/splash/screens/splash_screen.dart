import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_tracking.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/splash/viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashViewModel _viewModel;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _waveController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _waveAnimation;
  StreamSubscription<String?>? _routeSub;

  @override
  void initState() {
    super.initState();
    _viewModel = SplashViewModel();
    _initializeAnimations();
    _startAnimations();
    _viewModel.init();
    _routeSub = _viewModel.targetRoute$.listen((route) {
      if (route != null && mounted) context.go(route);
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _waveController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _routeSub?.cancel();
    _viewModel.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Book icon with fade + scale + wave
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _waveAnimation.value),
                      child: child,
                    );
                  },
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppGradients.primary(isDark).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            // READ-IT brand text
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                AppStrings.splashBrand.tr,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppTracking.editorial,
                  color: primary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Subtitle
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                AppStrings.splashTagline.tr,
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  letterSpacing: AppTracking.wide,
                  color: onSurfaceVariant,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          ],
        ),
      ),
    );
  }
}
