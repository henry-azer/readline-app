import 'package:flutter/material.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/reading/widgets/display_section_label.dart';
import 'package:readline_app/features/reading/widgets/display_slider_row.dart';
import 'package:readline_app/features/reading/widgets/font_family_card_row.dart';
import 'package:readline_app/features/reading/widgets/letter_spacing_pills.dart';
import 'package:readline_app/features/reading/widgets/style_toggle_pills.dart';
import 'package:readline_app/features/reading/widgets/text_alignment_pills.dart';

class DisplaySettingsTab extends StatelessWidget {
  final int fontSize;
  final double lineSpacing;
  final String fontFamily;
  final String letterSpacing;
  final String textAlignment;
  final double margin;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isDark;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color trackColor;
  final Color dividerColor;
  final ValueChanged<int> onFontSizeChanged;
  final ValueChanged<double> onLineSpacingChanged;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<String> onLetterSpacingChanged;
  final ValueChanged<String> onTextAlignmentChanged;
  final ValueChanged<double> onMarginChanged;
  final VoidCallback onBoldToggled;
  final VoidCallback onItalicToggled;
  final VoidCallback onUnderlineToggled;

  const DisplaySettingsTab({
    super.key,
    required this.fontSize,
    required this.lineSpacing,
    required this.fontFamily,
    required this.letterSpacing,
    required this.textAlignment,
    required this.margin,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.isDark,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.dividerColor,
    required this.onFontSizeChanged,
    required this.onLineSpacingChanged,
    required this.onFontFamilyChanged,
    required this.onLetterSpacingChanged,
    required this.onTextAlignmentChanged,
    required this.onMarginChanged,
    required this.onBoldToggled,
    required this.onItalicToggled,
    required this.onUnderlineToggled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        // ── Font Family cards ────────────────────────────────────────────
        DisplaySectionLabel(
          label: AppStrings.playerFontFamily.tr,
          color: onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.xs),
        FontFamilyCardRow(
          selected: fontFamily,
          primary: primary,
          onSurfaceVariant: onSurfaceVariant,
          trackColor: trackColor,
          onChanged: onFontFamilyChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Font size slider ────────────────────────────────────────────
        DisplaySliderRow(
          label: AppStrings.settingsFontSizeLabel.tr,
          value: '${fontSize}pt',
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          child: Slider(
            value: fontSize.toDouble(),
            min: AppConstants.minFontSize.toDouble(),
            max: AppConstants.maxFontSize.toDouble(),
            divisions:
                ((AppConstants.maxFontSize - AppConstants.minFontSize) /
                        AppConstants.fontSizeStep)
                    .round(),
            onChanged: (v) => onFontSizeChanged(v.round()),
          ),
        ),

        // ── Line height slider ──────────────────────────────────────────
        DisplaySliderRow(
          label: AppStrings.settingsLineSpacingLabel.tr,
          value: '${lineSpacing.toStringAsFixed(1)}x',
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.playerLineHeightCompact.tr,
                style: AppTypography.readingTinyLabel.copyWith(
                  color: onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '—',
                style: AppTypography.readingTinyLabel.copyWith(
                  color: onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                AppStrings.playerLineHeightSpacious.tr,
                style: AppTypography.readingTinyLabel.copyWith(
                  color: onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          child: Slider(
            value: lineSpacing,
            min: AppConstants.minLineSpacing,
            max: AppConstants.maxLineSpacing,
            divisions:
                ((AppConstants.maxLineSpacing - AppConstants.minLineSpacing) /
                        AppConstants.lineSpacingStep)
                    .round(),
            onChanged: (v) {
              final rounded = (v * 10).round() / 10;
              onLineSpacingChanged(rounded);
            },
          ),
        ),

        // ── Margin slider (paired with line spacing — both control the
        //    text block's vertical / horizontal breathing room) ──────────
        DisplaySliderRow(
          label: AppStrings.playerMargin.tr,
          value: '${margin.round()}px',
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          child: Slider(
            value: margin.clamp(AppConstants.minMargin, AppConstants.maxMargin),
            min: AppConstants.minMargin,
            max: AppConstants.maxMargin,
            divisions:
                ((AppConstants.maxMargin - AppConstants.minMargin) /
                        AppConstants.marginStep)
                    .round(),
            onChanged: onMarginChanged,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ── Letter spacing pills ────────────────────────────────────────
        DisplaySectionLabel(
          label: AppStrings.playerLetterSpacing.tr,
          color: onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.xs),
        LetterSpacingPills(
          selected: letterSpacing,
          primary: primary,
          onSurfaceVariant: onSurfaceVariant,
          trackColor: trackColor,
          onChanged: onLetterSpacingChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Text alignment pills (left / center / right / justify) ──────
        DisplaySectionLabel(
          label: AppStrings.playerTextAlignment.tr,
          color: onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextAlignmentPills(
          selected: textAlignment,
          primary: primary,
          onSurfaceVariant: onSurfaceVariant,
          trackColor: trackColor,
          onChanged: onTextAlignmentChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Style toggles (Bold / Italic / Underline) ───────────────────
        DisplaySectionLabel(
          label: AppStrings.playerTextStyle.tr,
          color: onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.xs),
        StyleTogglePills(
          isBold: isBold,
          isItalic: isItalic,
          isUnderline: isUnderline,
          primary: primary,
          onSurfaceVariant: onSurfaceVariant,
          trackColor: trackColor,
          onBoldToggled: onBoldToggled,
          onItalicToggled: onItalicToggled,
          onUnderlineToggled: onUnderlineToggled,
        ),
      ],
    );
  }
}
