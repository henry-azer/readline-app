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

class DocumentListTile extends StatelessWidget {
  final PdfDocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DocumentListTile({
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
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;

    final progress = document.totalPages > 0
        ? (document.currentPage / document.totalPages).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = document.readingStatus == 'completed';
    final progressColor = isCompleted ? AppColors.error : primary;
    final lastReadLabel = _formatLastRead(document.lastReadAt);

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            isDark
                ? AppColors.darkAmbientShadow(blur: 12, opacity: 0.2)
                : AppColors.ambientShadow(blur: 12, opacity: 0.05),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail / cover
            ClipRRect(
              borderRadius: AppRadius.mdBorder,
              child: Container(
                width: 56,
                height: 72,
                color: surfaceHigh,
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 28,
                    color: onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Document info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
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

                  const SizedBox(height: AppSpacing.xxs),

                  // Last read + complexity
                  Row(
                    children: [
                      if (lastReadLabel != null)
                        Text(
                          lastReadLabel,
                          style: AppTypography.label.copyWith(
                            color: onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      const Spacer(),
                      _ComplexityBadge(level: document.complexityLevel),
                    ],
                  ),
                ],
              ),
            ),

            // Delete icon
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: onSurfaceVariant.withValues(alpha: 0.6),
                ),
                padding: const EdgeInsets.all(AppSpacing.xs),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
      ),
    );
  }

  String? _formatLastRead(DateTime? lastReadAt) {
    if (lastReadAt == null) return null;
    final diff = DateTime.now().difference(lastReadAt);
    if (diff.inDays == 0) return AppStrings.todayUpper.tr;
    if (diff.inDays == 1) return AppStrings.yesterdayUpper.tr;
    if (diff.inDays < 7) {
      return AppStrings.daysAgoUpper.trParams({'n': '${diff.inDays}'});
    }
    if (diff.inDays < 30) {
      return AppStrings.weeksAgoUpper.trParams({
        'n': '${(diff.inDays / 7).floor()}',
      });
    }
    return AppStrings.monthsAgoUpper.trParams({
      'n': '${(diff.inDays / 30).floor()}',
    });
  }
}

class _ComplexityBadge extends StatelessWidget {
  final String level;

  const _ComplexityBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = _color(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        level.toUpperCase(),
        style: AppTypography.label.copyWith(color: color, fontSize: 9),
      ),
    );
  }

  Color _color(String level) {
    switch (level) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFF2196F3);
      case 'advanced':
        return const Color(0xFFFF9800);
      case 'expert':
        return const Color(0xFFF44336);
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}
