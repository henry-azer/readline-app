import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/utils/document_meta.dart';
import 'package:readline_app/features/library/widgets/cover_area.dart';
import 'package:readline_app/features/library/widgets/highlighted_text.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class DocumentGridCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final String? searchQuery;

  /// Words-per-minute used to estimate "min left" / "min total" — supplied by
  /// the library viewmodel from cached user prefs.
  final int wpm;

  /// Total minutes the user actually spent reading this document
  /// (sum of session durations). Only consulted for completed documents,
  /// where it overrides the WPM-based projection.
  final double? actualMinutes;

  const DocumentGridCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.searchQuery,
    this.wpm = 200,
    this.actualMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final outlineVariant = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;
    final successColor = isDark ? AppColors.success : AppColors.lightSuccess;

    final progress = document.totalWords > 0
        ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = document.isCompleted;
    final progressColor = isCompleted ? successColor : primary;
    final progressPercent = (progress * 100).round();
    final timeLabel = DocumentMeta.estimatedTime(
      document,
      wpm,
      actualMinutes: actualMinutes,
    );

    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            isDark
                ? AppColors.darkAmbientShadow(blur: 16, opacity: 0.25)
                : AppColors.ambientShadow(blur: 16, opacity: 0.06),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover area with status pill (TL) and edit/delete overlay (TR)
            Expanded(
              child: CoverArea(
                document: document,
                isDark: isDark,
                onEdit: onEdit,
                onDelete: onDelete,
                searchQuery: searchQuery,
              ),
            ),

            // Body — fixed height so the cover never resizes with content.
            SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    HighlightedText(
                      text: document.title,
                      query: searchQuery,
                      style: AppTypography.labelMedium.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      highlightColor: primary,
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Progress bar + percentage / completion check
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: outlineVariant.withValues(alpha: 0.4),
                                  borderRadius: AppRadius.fullBorder,
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: progressColor,
                                    borderRadius: AppRadius.fullBorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: successColor,
                          ),
                        ] else if (document.isInProgress) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            AppStrings.libraryProgressPercent.trParams({
                              'n': '$progressPercent',
                            }),
                            style: AppTypography.labelMicro.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Estimated time meta line — under the progress bar.
                    if (timeLabel != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 10,
                            color: onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.micro),
                          Expanded(
                            child: Text(
                              timeLabel,
                              style: AppTypography.labelTiny.copyWith(
                                color: onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
