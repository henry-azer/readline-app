import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/core/utils/date_formatter.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/features/reading/widgets/summary_hero_badge.dart';
import 'package:readline_app/features/reading/widgets/summary_stat_card.dart';
import 'package:readline_app/features/reading/widgets/title_hairline.dart';

class SessionSummaryDialog extends StatelessWidget {
  final ReadingSessionModel? session;
  final VoidCallback onDone;

  const SessionSummaryDialog({
    super.key,
    required this.session,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final outlineVariant = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;

    final s = session;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero icon: gradient disc with a soft outer ring ────────────
            Center(
              child: SummaryHeroBadge(isDark: isDark, primary: primary),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── "Session Complete" headline ────────────────────────────────
            Text(
              AppStrings.readingSessionComplete.tr,
              style: AppTypography.summaryHeadline.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // ── Document title — typeset like a book title:
            //    serif, italic, full-emphasis colour, tight leading.
            //    Framed with two hairline dashes for a chapter-divider feel.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleHairline(color: outlineVariant),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      s?.documentTitle ?? AppStrings.readingSessionEnded.tr,
                      style: AppTypography.summaryDocumentTitle.copyWith(
                        color: onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TitleHairline(color: outlineVariant),
                ],
              ),
            ),

            // ── Performance pill (only when we have stats) ────────────────
            if (s != null) ...[
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.fullBorder,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: primary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        s.performanceLabel.toUpperCase(),
                        style: AppTypography.summaryPerformancePill.copyWith(
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Stats grid: words / wpm / focus ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: SummaryStatCard(
                      icon: Icons.menu_book_rounded,
                      value: '${s.wordsRead}',
                      label: AppStrings.readingWordsRead.tr,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      outlineVariant: outlineVariant,
                      primary: primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SummaryStatCard(
                      icon: Icons.bolt_rounded,
                      value: '${s.averageWpm}',
                      label: AppStrings.readingAvgWpm.tr,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      outlineVariant: outlineVariant,
                      primary: primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SummaryStatCard(
                      icon: Icons.center_focus_strong_rounded,
                      value: '${s.focusScore.round()}%',
                      label: AppStrings.readingFocus.tr,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      outlineVariant: outlineVariant,
                      primary: primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Duration footer ───────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      DateFormatter.duration(s.durationMinutes),
                      style: AppTypography.summaryDuration.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // ── Done button ──────────────────────────────────────────────
            SizedBox(
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary(isDark),
                  borderRadius: AppRadius.lgBorder,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    borderRadius: AppRadius.lgBorder,
                    onTap: onDone,
                    child: Center(
                      child: Text(
                        AppStrings.readingDone.tr,
                        style: AppTypography.summaryDoneButton.copyWith(
                          color: isDark
                              ? AppColors.onPrimary
                              : AppColors.lightOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
