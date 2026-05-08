import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/data/models/streak_model.dart';

class GrowthInsightCard extends StatelessWidget {
  final List<ReadingSessionModel> recentSessions;
  final StreakModel streak;

  const GrowthInsightCard({
    super.key,
    required this.recentSessions,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Compute insight message from recent session data
    final insight = _computeInsight(recentSessions, streak);

    final cardBg = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final accentColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              size: 22,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.growthInsightLabel.tr,
                  style: AppTypography.analyticsLegend.copyWith(
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  insight,
                  style: AppTypography.analyticsInsightBody.copyWith(
                    color: onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _computeInsight(
    List<ReadingSessionModel> sessions,
    StreakModel streak,
  ) {
    if (sessions.isEmpty) {
      return AppStrings.growthInsightNoSessions.tr;
    }

    // Day-of-year drives variant rotation so the message changes daily.
    final now = DateTime.now();
    final dayIdx = now.difference(DateTime(now.year)).inDays;

    // Almost-record streak (within 5 days of personal best)
    if (streak.currentStreak > 0 &&
        streak.longestStreak > 0 &&
        streak.currentStreak < streak.longestStreak) {
      final daysAway = streak.longestStreak - streak.currentStreak;
      if (daysAway <= 5) {
        const variants = [
          AppStrings.growthInsightAlmostRecord,
          AppStrings.growthInsightAlmostRecord2,
        ];
        return variants[dayIdx % variants.length].trParams({
          'n': '$daysAway',
          'record': '${streak.longestStreak}',
        });
      }
    }

    // Speed up vs previous session
    if (sessions.length >= 2) {
      final latest = sessions.first.averageWpm;
      final previous = sessions[1].averageWpm;
      if (previous > 0 && latest > previous) {
        final pct = ((latest - previous) / previous * 100).round();
        if (pct >= 5) {
          const variants = [
            AppStrings.growthInsightSpeedUp,
            AppStrings.growthInsightSpeedUp2,
            AppStrings.growthInsightSpeedUp3,
          ];
          return variants[dayIdx % variants.length].trParams({'pct': '$pct'});
        }
      }
    }

    // High focus average
    final avgFocus =
        sessions.fold<double>(0, (s, r) => s + r.focusScore) / sessions.length;
    if (avgFocus >= 80) {
      const variants = [
        AppStrings.growthInsightFocus,
        AppStrings.growthInsightFocus2,
        AppStrings.growthInsightFocus3,
      ];
      return variants[dayIdx % variants.length].trParams({
        'pct': '${avgFocus.round()}',
      });
    }

    // Active streak (7+ days)
    if (streak.currentStreak >= 7) {
      const variants = [
        AppStrings.growthInsightStreak,
        AppStrings.growthInsightStreak2,
        AppStrings.growthInsightStreak3,
      ];
      return variants[dayIdx % variants.length].trParams({
        'n': '${streak.currentStreak}',
      });
    }

    // Default rotating pool — gentle reading-craft tips
    const defaultPool = [
      AppStrings.growthInsightConsistent,
      AppStrings.growthInsightDepth,
      AppStrings.growthInsightRhythm,
      AppStrings.growthInsightVocab,
      AppStrings.growthInsightShort,
      AppStrings.growthInsightMorning,
      AppStrings.growthInsightEvening,
      AppStrings.growthInsightDifficulty,
      AppStrings.growthInsightVariety,
      AppStrings.growthInsightCompound,
      AppStrings.growthInsightSilence,
      AppStrings.growthInsightReturn,
      AppStrings.growthInsightCuriosity,
    ];
    return defaultPool[dayIdx % defaultPool.length].tr;
  }
}
