import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';

/// Floating vocabulary interaction bar.
///
/// Displayed above the controls bar when a word is tapped in the focus zone.
/// Shows the selected word and a "SAVE TO VOCABULARY" action.
class VocabHighlight extends StatelessWidget {
  final String word;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  const VocabHighlight({
    super.key,
    required this.word,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
          border: Border(
            top: BorderSide(
              color:
                  (isDark
                          ? AppColors.outlineVariant
                          : AppColors.lightOutlineVariant)
                      .withValues(alpha: 0.2),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            // Word display
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.vocabCurrentContext.tr,
                    style: AppTypography.label.copyWith(
                      color: onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '"$word"',
                    style: AppTypography.titleMedium.copyWith(
                      color: onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Save button
            TextButton.icon(
              onPressed: onSave,
              style: TextButton.styleFrom(
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                  side: BorderSide(color: primary.withValues(alpha: 0.3)),
                ),
              ),
              icon: Icon(Icons.bookmark_add_outlined, size: 16, color: primary),
              label: Text(
                AppStrings.vocabSave.tr,
                style: AppTypography.button.copyWith(
                  color: primary,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.xs),

            // Dismiss
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: onSurfaceVariant,
              ),
              onPressed: onDismiss,
              tooltip: AppStrings.vocabDismiss.tr,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
