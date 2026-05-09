import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Top bar for the review session — close button, title, and progress bar.
class ReviewSessionHeader extends StatelessWidget {
  final int currentIndex;
  final int totalWords;
  final double progress;

  const ReviewSessionHeader({
    super.key,
    required this.currentIndex,
    required this.totalWords,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close_rounded, color: onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  AppStrings.reviewTitle.tr,
                  style: AppTypography.titleMedium.copyWith(color: onSurface),
                ),
              ),
              Text(
                AppStrings.generalProgressFraction.trParams({
                  'current': '${currentIndex + 1}',
                  'total': '$totalWords',
                }),
                style: AppTypography.labelMedium.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClipRRect(
              borderRadius: AppRadius.fullBorder,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? AppColors.surfaceContainerHigh
                    : AppColors.lightSurfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
