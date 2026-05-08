import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/splash/viewmodels/splash_viewmodel.dart';
import 'package:readline_app/features/splash/widgets/splash_book_mark.dart';
import 'package:readline_app/features/splash/widgets/splash_brand_title.dart';
import 'package:readline_app/features/splash/widgets/splash_tagline.dart';

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
      duration: AppDurations.splash,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: AppDurations.stagger,
      vsync: this,
    );

    _waveController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

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
            SplashBookMark(
              fade: _fadeAnimation,
              scale: _scaleAnimation,
              wave: _waveAnimation,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.xl),
            SplashBrandTitle(fade: _fadeAnimation, color: primary),
            const SizedBox(height: AppSpacing.xs),
            SplashTagline(fade: _fadeAnimation, color: onSurfaceVariant),
            const SizedBox(height: AppSpacing.xxxxl),
          ],
        ),
      ),
    );
  }
}
