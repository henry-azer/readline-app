import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class ContinueReadingCard extends StatelessWidget {
  final DocumentModel document;
  final int avgWpm;
  final int savedWpm;
  final HomeFeatureMode mode;
  final VoidCallback onContinueReading;

  const ContinueReadingCard({
    super.key,
    required this.document,
    required this.avgWpm,
    required this.savedWpm,
    required this.onContinueReading,
    this.mode = HomeFeatureMode.continueReading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final isStarting = mode == HomeFeatureMode.startNew;
    final isRereading = mode == HomeFeatureMode.readAgain;
    final progress = isStarting || isRereading
        ? 0.0
        : (document.totalWords > 0
              ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
              : 0.0);
    final estimatedMin = isStarting || isRereading
        ? _estimatedTotalMinutes()
        : _estimatedMinutesLeft();
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
                  // Top row: labels
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerKey.tr,
                        style: AppTypography.label.copyWith(
                          color: onSurface.withValues(alpha: 0.4),
                          letterSpacing: 2,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            _sourceTypeIcon(document.sourceType),
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
                              style: AppTypography.titleMedium.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _metaText(estimatedMin),
                        style: AppTypography.bodySmall.copyWith(
                          color: onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.msl),

                  // Progress bar
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

                  // Glass CTA button
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
                          style: AppTypography.labelMedium.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
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

  static IconData _sourceTypeIcon(String sourceType) {
    return switch (sourceType) {
      'text_input' => Icons.keyboard_rounded,
      'txt' => Icons.description_rounded,
      _ => Icons.picture_as_pdf_rounded,
    };
  }

  String _metaText(int estimatedMin) {
    final isFresh =
        mode == HomeFeatureMode.startNew || mode == HomeFeatureMode.readAgain;

    // Start / re-read: show time-to-read at the user's saved speed; skip
    // page count (always "0 / N", which is noise).
    if (isFresh) {
      if (estimatedMin <= 0) return '';
      return AppStrings.homeEstimatedTotal.trParams({'n': '$estimatedMin'});
    }

    final pages = AppStrings.homePagesProgress.trParams({
      'current': '${document.currentPage}',
      'total': '${document.totalPages}',
    });
    if (estimatedMin > 0) {
      final est = AppStrings.homeEstimatedLeft.trParams({'n': '$estimatedMin'});
      return '$pages  ·  $est';
    }
    return pages;
  }

  int _estimatedMinutesLeft() {
    final wordsLeft = document.totalWords - document.wordsRead;
    if (wordsLeft <= 0 || avgWpm <= 0) return 0;
    return (wordsLeft / avgWpm).ceil();
  }

  int _estimatedTotalMinutes() {
    final wpm = savedWpm > 0 ? savedWpm : avgWpm;
    if (document.totalWords <= 0 || wpm <= 0) return 0;
    return (document.totalWords / wpm).ceil();
  }
}
