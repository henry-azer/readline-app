import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/reading/widgets/summary_hero_badge.dart';
import 'package:readline_app/features/reading/widgets/summary_stat_card.dart';
import 'package:readline_app/features/vocabulary/viewmodels/review_session_viewmodel.dart';

/// Popup shown when a vocabulary review session finishes — mirrors the
/// reading-session summary dialog so the two completion experiences feel
/// like the same family.
class ReviewSummaryDialog extends StatelessWidget {
  final ReviewSessionResults results;
  final VoidCallback onDone;

  const ReviewSummaryDialog({
    super.key,
    required this.results,
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

    final accuracyPct = (results.accuracy * 100).round();

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
            Center(
              child: SummaryHeroBadge(isDark: isDark, primary: primary),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              AppStrings.reviewSessionComplete.tr,
              style: AppTypography.summaryHeadline.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            Text(
              AppStrings.reviewGreatWork.trParams({
                'count': '${results.totalReviewed}',
              }),
              style: AppTypography.bodyMedium.copyWith(
                color: onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: SummaryStatCard(
                    icon: Icons.fact_check_rounded,
                    value: '${results.totalReviewed}',
                    label: AppStrings.reviewLabelReviewed.tr,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    outlineVariant: outlineVariant,
                    primary: primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SummaryStatCard(
                    icon: Icons.auto_awesome_rounded,
                    value: '${results.mastered}',
                    label: AppStrings.reviewLabelMastered.tr,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    outlineVariant: outlineVariant,
                    primary: primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SummaryStatCard(
                    icon: Icons.percent_rounded,
                    value: '$accuracyPct%',
                    label: AppStrings.reviewLabelAccuracy.tr,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    outlineVariant: outlineVariant,
                    primary: primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

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
                        AppStrings.reviewDone.tr,
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
