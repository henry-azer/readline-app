import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/glass_container.dart';

/// Floating vocabulary interaction bar.
///
/// Displayed above the controls bar when a word is tapped in the focus zone.
/// Shows the selected word and a SAVE button that toggles the word's
/// vocabulary library membership (saves if not saved, removes if saved).
class VocabHighlight extends StatelessWidget {
  final String word;
  final bool isSaved;
  final VoidCallback onToggle;
  final VoidCallback onDismiss;

  /// Extra bottom padding added inside the colored container so the panel's
  /// background extends *behind* the controls bar while content stays at the
  /// top. Pass the controls bar height here to make the bar reach screen bottom.
  final double extraBottomPadding;

  const VocabHighlight({
    super.key,
    required this.word,
    required this.onToggle,
    required this.onDismiss,
    this.isSaved = false,
    this.extraBottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    // "Selected" treatment for the save toggle when the word is already in
    // the library — a soft tonal primary chip (filled-with-check icon and
    // a "SAVED" label) rather than the gray washed-out look. Reads as a
    // confirmation, while the lower fill alpha keeps it visually quieter
    // than the unsaved CTA.
    final selectedChipBg = primary.withValues(alpha: 0.14);

    return AnimatedSlide(
      offset: Offset.zero,
      duration: AppDurations.calm,
      curve: Curves.easeOutCubic,
      // Glass surface that matches the player controls bar — same blur,
      // same rounded top corners. The fill is near-opaque (≈92% alpha) so
      // the bar stays readable above the screen scrim; without that the
      // BackdropFilter samples the scrim and the bar looks dimmed.
      child: GlassContainer(
        blur: 16,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
        backgroundColor: (isDark
                ? AppColors.surfaceContainerHigh
                : AppColors.lightSurfaceContainerLowest)
            .withValues(alpha: 0.92),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + extraBottomPadding,
        ),
        child: Row(
          children: [
            // Word display
            Expanded(
              child: Text(
                '"$word"',
                style: AppTypography.readingHighlightWord.copyWith(
                  color: onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Save / Unsave toggle.
            // ─ Not saved → outlined primary CTA chip.
            // ─ Saved    → tonal primary chip with filled-with-check icon
            //              and a "SAVED" label; reads as a confirmation,
            //              still tappable to unsave.
            TextButton.icon(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                foregroundColor: primary,
                backgroundColor: isSaved ? selectedChipBg : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.smBorder,
                  side: isSaved
                      ? BorderSide.none
                      : BorderSide(color: primary.withValues(alpha: 0.3)),
                ),
              ),
              icon: Icon(
                isSaved
                    ? Icons.bookmark_added_rounded
                    : Icons.bookmark_add_outlined,
                size: 13,
                color: primary,
              ),
              label: Text(
                (isSaved ? AppStrings.vocabSaved : AppStrings.vocabSave).tr,
                style: AppTypography.readingMicroCta.copyWith(color: primary),
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
