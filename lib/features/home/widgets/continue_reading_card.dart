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
import 'package:readline_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class ContinueReadingCard extends StatelessWidget {
  final FeaturedDocument featured;
  final VoidCallback onContinueReading;

  const ContinueReadingCard({
    super.key,
    required this.featured,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final document = featured.document;
    final mode = featured.mode;
    final progress = featured.progress;
    final estimatedMin = featured.estimatedMinutes;

    final headerKey = switch (mode) {
      HomeFeatureMode.continueReading => AppStrings.homeContinueReading,
      HomeFeatureMode.startNew => AppStrings.homeReadyToStart,
      HomeFeatureMode.readAgain => AppStrings.homeReadAgainLabel,
    };
    final ctaKey = switch (mode) {
      HomeFeatureMode.continueReading => AppStrings.homeResume,
      HomeFeatureMode.startNew => AppStrings.homeStart,
      HomeFeatureMode.readAgain => AppStrings.homeStart,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: TapScale(
        onTap: onContinueReading,
        child: ClipRRect(
          borderRadius: AppRadius.lgBorder,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.mlg),
              decoration: BoxDecoration(
                color: AppColors.glassBackground(isDark),
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: AppColors.glassBorder(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerKey.tr,
                        style: AppTypography.homeEyebrowLabel.copyWith(
                          color: onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 14,
                            color: onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              document.title.isNotEmpty
                                  ? document.title
                                  : document.fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.homeFeaturedTitle.copyWith(
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _metaText(estimatedMin),
                        style: AppTypography.homeMetaCaption.copyWith(
                          color: onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.msl),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: AppDurations.reveal,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.glassTrack(isDark),
                          borderRadius: AppRadius.xsBorder,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.6),
                                  primaryColor.withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: AppRadius.xsBorder,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.msl),

                  ClipRRect(
                    borderRadius: AppRadius.mdBorder,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.smd,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glassInner(isDark),
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(
                            color: AppColors.glassBorder(isDark),
                          ),
                        ),
                        child: Text(
                          ctaKey.tr,
                          textAlign: TextAlign.center,
                          style: AppTypography.homeCtaLabel.copyWith(
                            color: onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _metaText(int estimatedMin) {
    if (estimatedMin <= 0) return '';
    final isFresh = featured.mode == HomeFeatureMode.startNew ||
        featured.mode == HomeFeatureMode.readAgain;
    return isFresh
        ? AppStrings.homeEstimatedTotal.trParams({'n': '$estimatedMin'})
        : AppStrings.homeEstimatedLeft.trParams({'n': '$estimatedMin'});
  }
}
