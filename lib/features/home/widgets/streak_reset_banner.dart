import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class StreakResetBanner extends StatefulWidget {
  final VoidCallback onDismiss;

  const StreakResetBanner({super.key, required this.onDismiss});

  @override
  State<StreakResetBanner> createState() => _StreakResetBannerState();
}

class _StreakResetBannerState extends State<StreakResetBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.smooth,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _autoDismissTimer = Timer(AppDurations.snackbarLong, _dismiss);
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: TapScale(
            onTap: _dismiss,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.tertiaryContainer
                    : AppColors.lightTertiary.withValues(alpha: 0.15),
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: isDark
                      ? AppColors.tertiary.withValues(alpha: 0.2)
                      : AppColors.lightTertiary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.tertiary
                        : AppColors.lightTertiaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppStrings.streakResetBanner.tr,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.tertiary
                            : AppColors.lightTertiaryContainer,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.tertiary.withValues(alpha: 0.5)
                        : AppColors.lightTertiaryContainer.withValues(
                            alpha: 0.5,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
