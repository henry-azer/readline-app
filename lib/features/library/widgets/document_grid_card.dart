import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/core/utils/date_formatter.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/widgets/highlighted_text.dart';
import 'package:readline_app/features/library/widgets/source_type_icon.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class DocumentGridCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final String? searchQuery;

  const DocumentGridCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.searchQuery,
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

    final progress = document.totalWords > 0
        ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = document.isCompleted;
    final isUnread = document.isUnread;
    final successColor = isDark ? AppColors.success : AppColors.lightSuccess;
    final progressColor = isCompleted ? successColor : primary;
    final progressPercent = (progress * 100).round();
    final lastReadAt = document.lastReadAt;

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
            // Cover / thumbnail area
            Expanded(
              child: _CoverArea(
                document: document,
                isDark: isDark,
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

                    // Description
                    if (document.description != null &&
                        document.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.micro),
                      HighlightedText(
                        text: document.description!,
                        query: searchQuery,
                        style: AppTypography.labelMicro.copyWith(
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                        highlightColor: primary,
                        maxLines: 1,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxs),

                    // Source type + page count row
                    Row(
                      children: [
                        Icon(
                          sourceTypeIcon(document.sourceType),
                          size: 10,
                          color: onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.micro),
                        Expanded(
                          child: Text(
                            AppStrings.libraryPageCount.trParams({
                              'current': '${document.currentPage}',
                              'total': '${document.totalPages}',
                            }),
                            style: AppTypography.labelTiny.copyWith(
                              color: onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Last read meta line
                    if (lastReadAt != null) ...[
                      const SizedBox(height: AppSpacing.micro),
                      Text(
                        DateFormatter.relative(lastReadAt),
                        style: AppTypography.labelTiny.copyWith(
                          color: onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xs),

                    // Progress bar + percentage label
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
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
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: AppSpacing.micro),
                          Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: successColor,
                          ),
                        ] else if (!isUnread) ...[
                          const SizedBox(width: AppSpacing.micro),
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

                    const SizedBox(height: AppSpacing.xxs),

                    // Status label
                    _StatusLabel(
                      status: document.isCompleted
                          ? 'completed'
                          : (document.isInProgress ? 'reading' : 'unread'),
                      isDark: isDark,
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
  final DocumentModel document;
  final bool isDark;

  const _CoverArea({
    required this.document,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

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
                    Icons.menu_book_rounded,
                    size: 36,
                    color: onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppStrings.libraryNoPreview.tr,
                    style: AppTypography.labelMicro.copyWith(
                      color: onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusLabel({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'completed' => (
        AppStrings.libraryStatusCompleted.tr,
        isDark ? AppColors.success : AppColors.lightSuccess,
      ),
      'reading' => (
        AppStrings.libraryStatusInProgress.tr,
        isDark
            ? AppColors.complexityIntermediate
            : AppColors.complexityIntermediate,
      ),
      _ => (
        AppStrings.libraryStatusNotStarted.tr,
        isDark ? AppColors.onSurfaceVariant : AppColors.lightOnSurfaceVariant,
      ),
    };

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.micro),
        Text(
          label,
          style: AppTypography.label.copyWith(color: color, fontSize: 8),
        ),
      ],
    );
  }
}
