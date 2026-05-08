import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class WordDefinitionSaveButton extends StatelessWidget {
  final bool isWordSaved;
  final VoidCallback onToggle;
  final bool isDark;
  final Color primary;

  const WordDefinitionSaveButton({
    super.key,
    required this.isWordSaved,
    required this.onToggle,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    // ─ Not saved → outlined primary CTA.
    // ─ Saved    → tonal primary chip (subtle fill) with filled-with-check
    //              icon and a "SAVED" label. Tonal alpha keeps emphasis low
    //              while the icon + label change clearly signals state.
    final selectedBg = primary.withValues(alpha: 0.14);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isWordSaved ? selectedBg : null,
          border: isWordSaved
              ? null
              : Border.all(color: primary.withValues(alpha: 0.3)),
          borderRadius: AppRadius.mdBorder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWordSaved
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
              size: 14,
              color: primary,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              (isWordSaved
                      ? AppStrings.dictSavedLabel
                      : AppStrings.dictSaveToVocab)
                  .tr,
              style: AppTypography.wordDefSaveButton.copyWith(color: primary),
            ),
          ],
        ),
      ),
    );
  }
}
