import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// CTA card shown when vocabulary words are due for review.
///
/// Shows the count of words due, source book info, and a "Start Review" button.
/// Only rendered when [dueCount] > 0.
class ReviewBloomCard extends StatelessWidget {
  final int dueCount;
  final VoidCallback onStartReview;

  const ReviewBloomCard({
    super.key,
    required this.dueCount,
    required this.onStartReview,
  });

  @override
  Widget build(BuildContext context) {
    if (dueCount == 0) return const SizedBox.shrink();

    final isDark = context.isDark;

    return TapScale(
      onTap: onStartReview,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryContainer,
                    AppColors.surfaceContainerHigh,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightPrimary,
                    AppColors.lightPrimaryContainer,
                  ],
                ),
          borderRadius: AppRadius.lgBorder,
          boxShadow: [
            isDark
                ? AppColors.darkAmbientShadow(blur: 24, opacity: 0.35)
                : AppColors.ambientShadow(blur: 16, opacity: 0.08),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: AppRadius.mdBorder,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.bloomDailyReview.tr,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.micro),
                  Text(
                    AppStrings.bloomWordsWaiting.trParams({
                      'count': '$dueCount',
                    }),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // CTA text button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.bloomStart.tr,
                  style: AppTypography.vocabBloomCta.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  AppStrings.bloomSession.tr,
                  style: AppTypography.vocabBloomCta.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.micro),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
