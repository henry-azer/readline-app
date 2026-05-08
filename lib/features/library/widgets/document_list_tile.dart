import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/widgets/highlighted_text.dart';
import 'package:readline_app/features/library/widgets/source_type_icon.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class DocumentListTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onLongPress;
  final String? searchQuery;

  const DocumentListTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onToggleSelect,
    this.onLongPress,
    this.searchQuery,
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

    final progress = document.totalWords > 0
        ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = document.isCompleted;
    final isUnread = document.isUnread;
    final successColor = isDark ? AppColors.success : AppColors.lightSuccess;
    final progressColor = isCompleted ? successColor : primary;
    final progressPercent = (progress * 100).round();
    final lastReadLabel = _formatLastRead(document.lastReadAt);

    final tileContent = TapScale(
      onTap: isMultiSelectMode ? onToggleSelect : onTap,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isSelected
                  ? primary
                  : outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              isDark
                  ? AppColors.darkAmbientShadow(blur: 12, opacity: 0.2)
                  : AppColors.ambientShadow(blur: 12, opacity: 0.05),
            ],
          ),
          child: Row(
            children: [
              // Multi-select checkbox or thumbnail
              if (isMultiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? primary : AppColors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? null
                          : Border.all(color: onSurfaceVariant, width: 1.5),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                )
              else
                // Thumbnail / cover
                ClipRRect(
                  borderRadius: AppRadius.mdBorder,
                  child: Container(
                    width: 56,
                    height: 72,
                    color: surfaceHigh,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            sourceTypeIcon(document.sourceType),
                            size: 28,
                            color: onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(width: AppSpacing.sm),

              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with status
                    Row(
                      children: [
                        Expanded(
                          child: HighlightedText(
                            text: document.title,
                            query: searchQuery,
                            style: AppTypography.titleMedium.copyWith(
                              color: onSurface,
                            ),
                            highlightColor: primary,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _StatusBadge(
                          status: document.isCompleted
                              ? 'completed'
                              : (document.isInProgress ? 'reading' : 'unread'),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Description
                    if (document.description != null &&
                        document.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.micro),
                      HighlightedText(
                        text: document.description!,
                        query: searchQuery,
                        style: AppTypography.labelSmall.copyWith(
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                        highlightColor: primary,
                        maxLines: 1,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxs),

                    // Page count
                    Text(
                      AppStrings.libraryPageCount.trParams({
                        'current': '${document.currentPage}',
                        'total': '${document.totalPages}',
                      }),
                      style: AppTypography.labelTiny.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),

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
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: successColor,
                          ),
                        ] else if (!isUnread) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            AppStrings.libraryProgressPercent.trParams({
                              'n': '$progressPercent',
                            }),
                            style: AppTypography.labelTiny.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxs),

                    // Last read + complexity
                    Row(
                      children: [
                        Icon(
                          sourceTypeIcon(document.sourceType),
                          size: 10,
                          color: onSurfaceVariant,
                        ),
                        if (lastReadLabel != null) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            lastReadLabel,
                            style: AppTypography.labelTiny.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                        const Spacer(),
                        _ComplexityBadge(level: document.complexityLevel),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions (only when not in multi-select mode)
              if (!isMultiSelectMode && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.buttonHeight,
                    minHeight: AppSpacing.buttonHeight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Wrap in Dismissible for swipe-to-delete in list mode
    if (onDelete != null && !isMultiSelectMode) {
      return Dismissible(
        key: ValueKey(document.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.error : AppColors.lightError).withValues(
              alpha: 0.15,
            ),
            borderRadius: AppRadius.lgBorder,
          ),
          child: Icon(
            Icons.delete_rounded,
            color: isDark ? AppColors.error : AppColors.lightError,
          ),
        ),
        confirmDismiss: (_) async {
          onDelete?.call();
          // Always return false — the onDelete callback handles
          // the confirmation dialog and actual deletion.
          return false;
        },
        child: tileContent,
      );
    }

    return tileContent;
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

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'completed' => (
        AppStrings.libraryStatusCompleted.tr,
        isDark ? AppColors.success : AppColors.lightSuccess,
        Icons.check_rounded,
      ),
      'reading' => (
        AppStrings.libraryStatusInProgress.tr,
        AppColors.complexityIntermediate,
        null,
      ),
      _ => (
        AppStrings.libraryStatusNotStarted.tr,
        isDark ? AppColors.onSurfaceVariant : AppColors.lightOnSurfaceVariant,
        null,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: AppSpacing.micro),
          ],
          Text(
            label,
            style: AppTypography.label.copyWith(color: color, fontSize: 8),
          ),
        ],
      ),
    );
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
        style: AppTypography.labelMicro.copyWith(color: color),
      ),
    );
  }

  Color _color(String level) {
    switch (level) {
      case 'beginner':
        return AppColors.complexityBeginner;
      case 'intermediate':
        return AppColors.complexityIntermediate;
      case 'advanced':
        return AppColors.complexityAdvanced;
      case 'expert':
        return AppColors.complexityExpert;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}
