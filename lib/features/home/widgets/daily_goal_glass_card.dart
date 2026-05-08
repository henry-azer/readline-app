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
import 'package:readline_app/widgets/progress_ring_painter.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class DailyGoalGlassCard extends StatelessWidget {
  final double todayMinutes;
  final int targetMinutes;
  final VoidCallback? onEditTap;

  const DailyGoalGlassCard({
    super.key,
    required this.todayMinutes,
    required this.targetMinutes,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final progress = targetMinutes > 0
        ? (todayMinutes / targetMinutes).clamp(0.0, 1.5)
        : 0.0;
    final ringProgress = progress.clamp(0.0, 1.0);
    final isComplete = todayMinutes >= targetMinutes;

    return TapScale(
      onTap: onEditTap,
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
              border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ringProgress),
                    duration: AppDurations.reveal,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return CustomPaint(
                        painter: ProgressRingPainter(
                          progress: value,
                          ringColor: primaryColor,
                          trackColor: AppColors.glassTrack(isDark),
                          strokeWidth: 4,
                        ),
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: isComplete
                                      ? '$targetMinutes'
                                      : todayMinutes.toStringAsFixed(0),
                                  style: AppTypography.homeStatNumberSmall
                                      .copyWith(color: primaryColor),
                                ),
                                TextSpan(
                                  text: AppStrings.homeMinutesSuffix.tr,
                                  style: AppTypography.homeMicroLabelTiny
                                      .copyWith(color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isComplete
                      ? AppStrings.homeMinReadToday.trParams({
                          'n': todayMinutes.toStringAsFixed(0),
                        })
                      : AppStrings.homeDailyGoalOf.trParams({
                          'n': '$targetMinutes',
                        }),
                  style: AppTypography.homeProgressMicroLabel.copyWith(
                    color: primaryColor.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
