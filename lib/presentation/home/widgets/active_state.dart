import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/pdf_document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/presentation/widgets/read_it_button.dart';

class ActiveState extends StatelessWidget {
  final PdfDocumentModel document;
  final List<ReadingSessionModel> recentSessions;
  final StreakModel streak;
  final VoidCallback onContinueReading;

  const ActiveState({
    super.key,
    required this.document,
    required this.recentSessions,
    required this.streak,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),

        // Streak card (shown only if streak > 0)
        if (streak.currentStreak > 0) ...[
          _StreakCard(streak: streak),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Current book card
        _CurrentBookCard(
          document: document,
          onContinueReading: onContinueReading,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Recent sessions
        if (recentSessions.isNotEmpty) ...[
          _RecentSessionsSection(sessions: recentSessions),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ],
    );
  }
}

// ── Streak card ────────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final StreakModel streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.streakLight,
        borderRadius: AppRadius.lgBorder,
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeStreakDays.trParams({
                    'n': '${streak.currentStreak}',
                  }),
                  style: AppTypography.label.copyWith(
                    color: AppColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  streak.milestoneLabel != null
                      ? AppStrings.homeStreakMilestone.trParams({
                          'milestone': streak.milestoneLabel!,
                        })
                      : AppStrings.homeStreakKeepGoing.tr,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          // Weekly dots
          _WeeklyDots(activity: streak.weeklyActivity, isDark: isDark),
        ],
      ),
    );
  }
}

class _WeeklyDots extends StatelessWidget {
  final List<bool> activity;
  final bool isDark;

  const _WeeklyDots({required this.activity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final days = [
      AppStrings.dayMon.tr[0],
      AppStrings.dayTue.tr[0],
      AppStrings.dayWed.tr[0],
      AppStrings.dayThu.tr[0],
      AppStrings.dayFri.tr[0],
      AppStrings.daySat.tr[0],
      AppStrings.daySun.tr[0],
    ];
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (i) {
            final active = i < activity.length && activity[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                days[i],
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 8,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Current book card ──────────────────────────────────────────────────────────

class _CurrentBookCard extends StatelessWidget {
  final PdfDocumentModel document;
  final VoidCallback onContinueReading;

  const _CurrentBookCard({
    required this.document,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surfaceColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final borderColor = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    // Progress 0.0–1.0
    final progress = document.totalWords > 0
        ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
        boxShadow: [AppColors.ambientShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            AppStrings.homeContinueReading.tr,
            style: AppTypography.label.copyWith(
              color: primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Title row
          Row(
            children: [
              // Book icon placeholder
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color:
                      (isDark
                              ? AppColors.primaryContainer
                              : AppColors.lightPrimaryContainer)
                          .withValues(alpha: 0.3),
                  borderRadius: AppRadius.smBorder,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title.isNotEmpty
                          ? document.title
                          : document.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppStrings.homeProgressComplete.trParams({
                        'pct': (progress * 100).toStringAsFixed(0),
                      }),
                      style: AppTypography.bodySmall.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.fullBorder,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: borderColor.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats row
          Row(
            children: [
              _MiniStat(
                icon: Icons.auto_stories_rounded,
                label:
                    '${document.totalPages > 0 ? document.currentPage : 0} / ${document.totalPages} pages',
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.md),
              _MiniStat(
                icon: Icons.text_fields_rounded,
                label: AppStrings.homeWordsRead.trParams({
                  'n': _formatWords(document.wordsRead),
                }),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // CTA
          ReadItButton(
            label: AppStrings.homeContinueReading.tr,
            icon: Icons.play_arrow_rounded,
            onTap: onContinueReading,
          ),
        ],
      ),
    );
  }

  String _formatWords(int words) {
    if (words >= 1000) return '${(words / 1000).toStringAsFixed(0)}k';
    return '$words';
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall.copyWith(color: color)),
      ],
    );
  }
}

// ── Recent sessions ────────────────────────────────────────────────────────────

class _RecentSessionsSection extends StatelessWidget {
  final List<ReadingSessionModel> sessions;

  const _RecentSessionsSection({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            AppStrings.homeRecentActivity.tr,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...sessions
            .take(3)
            .map((s) => _SessionTile(session: s, isDark: isDark)),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ReadingSessionModel session;
  final bool isDark;

  const _SessionTile({required this.session, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final borderColor = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final mins = session.durationMinutes.toStringAsFixed(0);
    final dateLabel = _relativeDate(session.startedAt);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.documentTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(color: onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel • ${AppStrings.homeMinSession.trParams({'n': mins})}',
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.smBorder,
            ),
            child: Text(
              AppStrings.homeSessionWpm.trParams({
                'n': '${session.averageWpm}',
              }),
              style: AppTypography.label.copyWith(
                color: primaryColor,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return AppStrings.today.tr;
    if (diff.inDays == 1) return AppStrings.yesterday.tr;
    if (diff.inDays < 7) {
      return AppStrings.daysAgo.trParams({'n': '${diff.inDays}'});
    }
    return '${date.day}/${date.month}';
  }
}
