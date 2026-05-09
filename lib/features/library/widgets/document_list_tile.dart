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
  final String? searchQuery;

  /// Words-per-minute used to estimate "min left" / "min total" — supplied by
  /// the library viewmodel from cached user prefs.
  final int wpm;

  const DocumentListTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.searchQuery,
    this.wpm = 200,
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
    final successColor = isDark ? AppColors.success : AppColors.lightSuccess;

    final progress = document.totalWords > 0
        ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = document.isCompleted;
    final isUnread = document.isUnread;
    final progressColor = isCompleted ? successColor : primary;
    final progressPercent = (progress * 100).round();
    final lastReadLabel = _formatLastRead(document.lastReadAt);
    final minutesLabel = _estimatedMinutes();

    final tileContent = TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            isDark
                ? AppColors.darkAmbientShadow(blur: 12, opacity: 0.2)
                : AppColors.ambientShadow(blur: 12, opacity: 0.05),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.smdBorder,
              ),
              child: Icon(
                sourceTypeIcon(document.sourceType),
                size: 22,
                color: primary,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

              // Body: title row, progress, meta row.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                    const SizedBox(height: AppSpacing.xs),

                    // Progress bar + percentage / completion check
                    Row(
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

                    const SizedBox(height: AppSpacing.xs),

                    // Meta row: estimated minutes + last read + complexity
                    Row(
                      children: [
                        if (minutesLabel != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.micro),
                          Flexible(
                            child: Text(
                              minutesLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelTiny.copyWith(
                                color: onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (lastReadLabel != null) ...[
                            Text(
                              ' · ',
                              style: AppTypography.labelTiny.copyWith(
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                        if (lastReadLabel != null)
                          Flexible(
                            child: Text(
                              lastReadLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelTiny.copyWith(
                                color: onSurfaceVariant,
                              ),
                            ),
                          ),
                        const Spacer(),
                        _ComplexityBadge(level: document.complexityLevel),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(width: AppSpacing.xxs),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.buttonHeight,
                      minHeight: AppSpacing.buttonHeight,
                    ),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: (isDark
                              ? AppColors.error
                              : AppColors.lightError)
                          .withValues(alpha: 0.7),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.buttonHeight,
                      minHeight: AppSpacing.buttonHeight,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    // Wrap in Dismissible for swipe-to-delete in list mode
    if (onDelete != null) {
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

  String? _estimatedMinutes() {
    if (wpm <= 0 || document.totalWords <= 0) return null;
    if (document.isInProgress) {
      final wordsLeft = document.totalWords - document.wordsRead;
      if (wordsLeft <= 0) return null;
      final mins = (wordsLeft / wpm).ceil();
      if (mins <= 0) return null;
      return AppStrings.homeEstimatedLeft.trParams({'n': '$mins'});
    }
    final mins = (document.totalWords / wpm).ceil();
    if (mins <= 0) return null;
    return AppStrings.homeEstimatedTotal.trParams({'n': '$mins'});
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
        isDark ? AppColors.primary : AppColors.lightPrimary,
        null,
      ),
      _ => (
        AppStrings.libraryStatusNotStarted.tr,
        isDark ? AppColors.onSurfaceVariant : AppColors.lightOnSurfaceVariant,
        null,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
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
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
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
