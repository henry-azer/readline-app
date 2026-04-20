import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';

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
        ? AppColors.surfaceContainerHigh
        : const Color(0xFFF0EDE7); // warm parchment tint in light
    final accentColor = isDark
        ? AppColors.tertiary
        : AppColors.lightTertiaryContainer;
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
                  style: AppTypography.label.copyWith(
                    color: accentColor,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  insight,
                  style: AppTypography.bodyMedium.copyWith(
                    color: onSurface,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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

    // Check streak milestone
    if (streak.currentStreak > 0 &&
        streak.longestStreak > 0 &&
        streak.currentStreak < streak.longestStreak) {
      final daysAway = streak.longestStreak - streak.currentStreak;
      if (daysAway <= 5) {
        return AppStrings.growthInsightAlmostRecord.trParams({
          'n': '$daysAway',
          'record': '${streak.longestStreak}',
        });
      }
    }

    // Compare last two sessions' WPM for trend
    if (sessions.length >= 2) {
      final latest = sessions.first.averageWpm;
      final previous = sessions[1].averageWpm;
      if (previous > 0 && latest > previous) {
        final pct = ((latest - previous) / previous * 100).round();
        if (pct >= 5) {
          return AppStrings.growthInsightSpeedUp.trParams({'pct': '$pct'});
        }
      }
    }

    // Focus score insight
    final avgFocus = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (s, r) => s + r.focusScore) /
              sessions.length;
    if (avgFocus >= 80) {
      return AppStrings.growthInsightFocus.trParams({
        'pct': '${avgFocus.round()}',
      });
    }

    // Streak motivator
    if (streak.currentStreak >= 7) {
      return AppStrings.growthInsightStreak.trParams({
        'n': '${streak.currentStreak}',
      });
    }

    // Vocab encouragement
    return AppStrings.growthInsightConsistent.tr;
  }
}
