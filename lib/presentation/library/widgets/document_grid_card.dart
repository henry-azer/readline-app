import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/pdf_document_model.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class DocumentGridCard extends StatelessWidget {
  final PdfDocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DocumentGridCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final outlineVariant = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;

    final progress = document.totalPages > 0
        ? (document.currentPage / document.totalPages).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = document.readingStatus == 'completed';
    final progressColor = isCompleted ? AppColors.error : primary;

    return TapScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            isDark
                ? AppColors.darkAmbientShadow(blur: 16, opacity: 0.25)
                : AppColors.ambientShadow(blur: 16, opacity: 0.06),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover / thumbnail area
            Expanded(
              child: _CoverArea(
                document: document,
                isDark: isDark,
                onDelete: onDelete,
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    document.title,
                    style: AppTypography.labelMedium.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xxs),

                  // Page count
                  Text(
                    AppStrings.libraryPageCount.trParams({
                      'current': '${document.currentPage}',
                      'total': '${document.totalPages}',
                    }),
                    style: AppTypography.label.copyWith(
                      color: onSurfaceVariant,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: outlineVariant.withValues(alpha: 0.4),
                          borderRadius: AppRadius.fullBorder,
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: AppRadius.fullBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverArea extends StatelessWidget {
  final PdfDocumentModel document;
  final bool isDark;
  final VoidCallback? onDelete;

  const _CoverArea({
    required this.document,
    required this.isDark,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final isCompleted = document.readingStatus == 'completed';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background placeholder
          Container(
            color: surfaceHigh,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 36,
                    color: onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppStrings.libraryNoPreview.tr,
                    style: AppTypography.label.copyWith(
                      color: onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Completed badge (top right)
          if (isCompleted)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
            ),

          // Delete button (top right, if not completed badge)
          if (!isCompleted && onDelete != null)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? AppColors.surfaceContainer
                                : AppColors.lightSurface)
                            .withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    size: 14,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
