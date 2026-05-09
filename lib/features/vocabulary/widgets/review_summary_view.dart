import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/vocabulary/viewmodels/review_session_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/review_summary_stat_row.dart';
import 'package:readline_app/widgets/readline_button.dart';

/// End-of-session summary: hero icon, headline, stat rows, and a "Done" CTA.
class ReviewSummaryView extends StatelessWidget {
  final ReviewSessionViewModel viewModel;
  final VoidCallback onClose;

  const ReviewSummaryView({
    super.key,
    required this.viewModel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return StreamBuilder<ReviewSessionResults>(
      stream: viewModel.results$,
      builder: (context, snap) {
        final results = snap.data ?? const ReviewSessionResults();
        final accuracyPct = (results.accuracy * 100).round();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerHigh
                      : AppColors.lightSurfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  results.mastered > 0
                      ? Icons.auto_awesome_rounded
                      : Icons.school_outlined,
                  size: 36,
                  color: primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                AppStrings.reviewSessionComplete.tr,
                style: AppTypography.displayMedium.copyWith(color: onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                results.totalReviewed == 0
                    ? AppStrings.reviewNoWordsDue.tr
                    : AppStrings.reviewGreatWork.trParams({
                        'count': '${results.totalReviewed}',
                      }),
                style: AppTypography.bodyMedium.copyWith(
                  color: onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              if (results.totalReviewed > 0) ...[
                ReviewSummaryStatRow(
                  label: AppStrings.reviewLabelReviewed.tr,
                  value: '${results.totalReviewed}',
                ),
                ReviewSummaryStatRow(
                  label: AppStrings.reviewLabelMastered.tr,
                  value: '${results.mastered}',
                  valueColor: isDark
                      ? AppColors.success
                      : AppColors.lightSuccess,
                ),
                ReviewSummaryStatRow(
                  label: AppStrings.reviewLabelStillLearning.tr,
                  value: '${results.stillLearning}',
                  valueColor: isDark
                      ? AppColors.tertiary
                      : AppColors.lightTertiary,
                ),
                ReviewSummaryStatRow(
                  label: AppStrings.reviewLabelAccuracy.tr,
                  value: '$accuracyPct%',
                  valueColor: primary,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              SizedBox(
                width: double.infinity,
                child: ReadlineButton(
                  label: AppStrings.reviewDone.tr,
                  onTap: onClose,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
