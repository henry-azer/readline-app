import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/utils/cover_palette.dart';
import 'package:readline_app/features/library/utils/document_meta.dart';
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

  const DocumentGridCard({
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
    final wordCountLabel = AppStrings.libraryWordCount.trParams({
      'n': DocumentMeta.wordCount(document.totalWords),
    });
    final timeLabel = DocumentMeta.estimatedTime(document, wpm);

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
              child: _CoverArea(
                document: document,
                isDark: isDark,
                onEdit: onEdit,
                onDelete: onDelete,
                searchQuery: searchQuery,
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
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

                  const SizedBox(height: AppSpacing.xs),

                  // Word count meta line
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 10,
                        color: onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.micro),
                      Expanded(
                        child: Text(
                          wordCountLabel,
                          style: AppTypography.labelTiny.copyWith(
                            color: onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Estimated time meta line
                  if (timeLabel != null) ...[
                    const SizedBox(height: AppSpacing.micro),
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
                        const SizedBox(width: AppSpacing.micro),
                        Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: successColor,
                        ),
                      ] else if (document.isInProgress) ...[
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? searchQuery;

  const _CoverArea({
    required this.document,
    required this.isDark,
    this.onEdit,
    this.onDelete,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = CoverPalette.forTitle(
      document.title,
      isDark: isDark,
    );
    final titleColor = CoverPalette.titleColor(isDark: isDark);
    final highlightColor = isDark
        ? AppColors.primary
        : AppColors.lightPrimary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background — title-derived, stable per document.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),

          // Centered editorial title with search highlighting.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xl,
            ),
            child: Center(
              child: HighlightedText(
                text: document.title,
                query: searchQuery,
                maxLines: 3,
                style: AppTypography.coverTitle.copyWith(
                  fontSize: CoverPalette.titleFontSize(document.title),
                  color: titleColor,
                  shadows: isDark
                      ? null
                      : [
                          Shadow(
                            blurRadius: 0,
                            offset: const Offset(0, 1),
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ],
                ),
                highlightColor: highlightColor,
              ),
            ),
          ),

          // Status pill (top-left)
          Positioned(
            top: AppSpacing.xs,
            left: AppSpacing.xs,
            child: _StatusPill(
              status: document.isCompleted
                  ? 'completed'
                  : (document.isInProgress ? 'reading' : 'unread'),
              isDark: isDark,
            ),
          ),

          // Edit / delete overlay (top-right)
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  _CoverIconButton(
                    icon: Icons.edit_outlined,
                    onTap: onEdit!,
                    isDark: isDark,
                    isDestructive: false,
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: AppSpacing.micro),
                if (onDelete != null)
                  _CoverIconButton(
                    icon: Icons.delete_outline_rounded,
                    onTap: onDelete!,
                    isDark: isDark,
                    isDestructive: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _CoverIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final bg = (isDark
            ? AppColors.surfaceContainerHigh
            : AppColors.lightSurfaceContainerHigh)
        .withValues(alpha: 0.85);
    final iconColor = isDestructive
        ? (isDark ? AppColors.error : AppColors.lightError)
              .withValues(alpha: 0.85)
        : (isDark
              ? AppColors.onSurfaceVariant
              : AppColors.lightOnSurfaceVariant);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusPill({required this.status, required this.isDark});

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
    final bg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.85)
        : AppColors.lightSurfaceContainerHigh.withValues(alpha: 0.85);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: AppSpacing.micro),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.micro),
          ],
          Text(
            label,
            style: AppTypography.labelMicro.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
