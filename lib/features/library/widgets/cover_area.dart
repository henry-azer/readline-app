import 'package:flutter/material.dart';
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
import 'package:readline_app/features/library/widgets/cover_action_stack.dart';
import 'package:readline_app/features/library/widgets/cover_status_pill.dart';
import 'package:readline_app/features/library/widgets/highlighted_text.dart';

/// Editorial cover area for the document grid card — gradient background,
/// centered title, word-count footer, status pill, and edit/delete overlay.
class CoverArea extends StatelessWidget {
  final DocumentModel document;
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? searchQuery;

  const CoverArea({
    super.key,
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
                            color: AppColors.white.withValues(alpha: 0.4),
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
                style: AppTypography.labelNano.copyWith(
                  color: titleColor.withValues(alpha: 0.75),
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
            child: CoverStatusPill(
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
            child: CoverActionStack(
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
