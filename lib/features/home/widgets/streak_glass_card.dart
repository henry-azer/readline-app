import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class StreakGlassCard extends StatelessWidget {
  final StreakModel streak;
  final bool todayTargetMet;
  final VoidCallback? onTap;

  const StreakGlassCard({
    super.key,
    required this.streak,
    required this.todayTargetMet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isZero = streak.currentStreak == 0;
    final isActive = !isZero && todayTargetMet;
    final accent = isDark ? AppColors.primary : AppColors.lightPrimary;
    final streakColor = isZero
        ? (isDark
              ? AppColors.onSurfaceVariant
              : AppColors.lightOnSurfaceVariant)
        : isActive
        ? accent
        : accent.withValues(alpha: 0.9);

    return TapScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassBackground(isDark),
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: streakColor.withValues(alpha: 0.10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: streak.currentStreak),
                  duration: AppDurations.reveal,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: streakColor,
                        ),
                        const SizedBox(width: AppSpacing.micro),
                        Text(
                          '$value',
                          style: AppTypography.homeStatNumber.copyWith(
                            color: streakColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  isZero
                      ? AppStrings.homeStreakLabelZero.tr
                      : AppStrings.homeStreakLabel.tr,
                  style: AppTypography.homeProgressMicroLabel.copyWith(
                    color: streakColor.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    final active =
                        i < streak.weeklyActivity.length &&
                        streak.weeklyActivity[i];
                    return Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 3.0 : 0),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? streakColor
                              : streakColor.withValues(alpha: 0.15),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
