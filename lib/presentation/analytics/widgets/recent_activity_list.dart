import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/reading_session_model.dart';

class RecentActivityList extends StatelessWidget {
  final List<ReadingSessionModel> sessions;

  const RecentActivityList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return _EmptyActivity();
    }

    return Column(
      children: sessions.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _ActivityItem(session: s),
        );
      }).toList(),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.analyticsNoSessions.tr,
              style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity item ─────────────────────────────────────────────────────────────

class _ActivityItem extends StatelessWidget {
  final ReadingSessionModel session;

  const _ActivityItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final dateLabel = _formatDate(session.startedAt);
    final durationLabel = _formatDuration(session.durationMinutes);
    final performanceBg = _performanceBgColor(session.performanceLabel, isDark);
    final performanceText = _performanceTextColor(
      session.performanceLabel,
      isDark,
    );

    return GestureDetector(
      onTap: () {
        // Navigate to reading screen for this document
        context.push('${AppRoutes.reading}/${session.documentId}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.lgBorder,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Doc icon
            Container(
              width: 44,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceContainerHighest
                    : AppColors.lightSurfaceContainerHigh,
                borderRadius: AppRadius.smBorder,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 22,
                color: onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.documentTitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppStrings.analyticsSessionLabel.trParams({
                      'date': dateLabel,
                      'duration': durationLabel,
                    }),
                    style: AppTypography.label.copyWith(
                      color: onSurfaceVariant,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // WPM badge + performance label
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(color: onSurface),
                    children: [
                      TextSpan(
                        text: '${session.averageWpm}',
                        style: AppTypography.titleMedium.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: AppStrings.analyticsWpm.tr,
                        style: AppTypography.bodySmall.copyWith(
                          color: onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: performanceBg,
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Text(
                    session.performanceLabel.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      color: performanceText,
                      fontSize: 9,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(sessionDay).inDays;
    if (diff == 0) return AppStrings.todayUpper.tr;
    if (diff == 1) return AppStrings.yesterdayUpper.tr;
    if (diff < 7) return AppStrings.daysAgoUpper.trParams({'n': '$diff'});
    return '${dt.day} ${_monthAbbr(dt.month)}';
  }

  String _formatDuration(double minutes) {
    if (minutes < 1) return AppStrings.analyticsLessThanOneMin.tr;
    return AppStrings.analyticsMins.trParams({'n': '${minutes.round()}'});
  }

  static const _monthKeys = [
    AppStrings.monthJan,
    AppStrings.monthFeb,
    AppStrings.monthMar,
    AppStrings.monthApr,
    AppStrings.monthMay,
    AppStrings.monthJun,
    AppStrings.monthJul,
    AppStrings.monthAug,
    AppStrings.monthSep,
    AppStrings.monthOct,
    AppStrings.monthNov,
    AppStrings.monthDec,
  ];

  String _monthAbbr(int month) {
    return _monthKeys[month - 1].tr.toUpperCase();
  }

  Color _performanceBgColor(String label, bool isDark) {
    final lower = label.toLowerCase();
    if (lower.contains('exception')) {
      return isDark ? const Color(0xFF1A3A2A) : const Color(0xFFD6F5E3);
    }
    if (lower.contains('steady')) {
      return isDark ? const Color(0xFF1A2A3A) : const Color(0xFFD6E8F5);
    }
    return isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;
  }

  Color _performanceTextColor(String label, bool isDark) {
    final lower = label.toLowerCase();
    if (lower.contains('exception')) {
      return isDark ? const Color(0xFF6EE7A0) : const Color(0xFF1A5C35);
    }
    if (lower.contains('steady')) {
      return isDark ? const Color(0xFF7EC8E3) : const Color(0xFF1A3F5C);
    }
    return isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
  }
}
