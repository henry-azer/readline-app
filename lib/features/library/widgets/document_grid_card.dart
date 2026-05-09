import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_tracking.dart';
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
              child: _CoverArea(
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
    final highlightColor = isDark ? AppColors.primary : AppColors.lightPrimary;

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

          // Word count badge centered along the bottom of the cover.
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.xs,
            child: Center(
              child: Text(
                '— ${AppStrings.libraryWordCount.trParams({'n': DocumentMeta.wordCount(document.totalWords)})} —',
                style: AppTypography.labelMicro.copyWith(
                  color: titleColor.withValues(alpha: 0.75),
                  fontSize: 8,
                  fontWeight: FontWeight.w300,
                  letterSpacing: AppTracking.wide,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

          // Edit / delete overlay (top-right) — glass pill with stacked icons.
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: _CoverActionStack(
              isDark: isDark,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverActionStack extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CoverActionStack({
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();

    // Match the cover title's contrast (light text on dark gradient,
    // near-black on light gradient) with a subtle alpha so the icons
    // read as muted controls rather than primary CTAs.
    final iconColor = CoverPalette.titleColor(
      isDark: isDark,
    ).withValues(alpha: 0.7);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          _CoverIconButton(
            icon: Icons.edit_outlined,
            onTap: onEdit!,
            color: iconColor,
          ),
        if (onDelete != null)
          _CoverIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: onDelete!,
            color: iconColor,
          ),
      ],
    );
  }
}

class _CoverIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CoverIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.micro,
        ),
        child: Icon(icon, size: 14, color: color),
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
          Text(label, style: AppTypography.labelMicro.copyWith(color: color)),
        ],
      ),
    );
  }
}
