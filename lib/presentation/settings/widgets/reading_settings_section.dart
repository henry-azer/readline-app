import 'package:flutter/material.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/user_preferences_model.dart';
import 'package:read_it/presentation/settings/viewmodels/settings_viewmodel.dart';

class ReadingSettingsSection extends StatelessWidget {
  final SettingsViewModel viewModel;
  final UserPreferencesModel prefs;

  const ReadingSettingsSection({
    super.key,
    required this.viewModel,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final trackColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;

    final sliderTheme = SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: trackColor,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.12),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SliderTheme(
        data: sliderTheme,
        child: Column(
          children: [
            _SliderRow(
              label: AppStrings.settingsSpeedLabel.tr,
              value: prefs.readingSpeedWpm.toDouble(),
              displayValue: '${prefs.readingSpeedWpm}',
              min: AppConstants.minWpm.toDouble(),
              max: AppConstants.maxWpm.toDouble(),
              divisions:
                  ((AppConstants.maxWpm - AppConstants.minWpm) /
                          AppConstants.wpmStep)
                      .round(),
              onChanged: (v) => viewModel.previewSpeed(v.round()),
              onChangeEnd: (v) => viewModel.updateSpeed(v.round()),
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _Divider(isDark: isDark),
            _SliderRow(
              label: AppStrings.settingsLineSpacingLabel.tr,
              value: prefs.lineSpacing,
              displayValue: '${prefs.lineSpacing.toStringAsFixed(1)}x',
              min: AppConstants.minLineSpacing,
              max: AppConstants.maxLineSpacing,
              divisions:
                  ((AppConstants.maxLineSpacing - AppConstants.minLineSpacing) /
                          AppConstants.lineSpacingStep)
                      .round(),
              onChanged: (v) =>
                  viewModel.previewLineSpacing((v * 10).round() / 10),
              onChangeEnd: (v) =>
                  viewModel.updateLineSpacing((v * 10).round() / 10),
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _Divider(isDark: isDark),
            _SliderRow(
              label: AppStrings.settingsFontSizeLabel.tr,
              value: prefs.fontSize.toDouble(),
              displayValue: '${prefs.fontSize}pt',
              min: AppConstants.minFontSize.toDouble(),
              max: AppConstants.maxFontSize.toDouble(),
              divisions:
                  ((AppConstants.maxFontSize - AppConstants.minFontSize) /
                          AppConstants.fontSizeStep)
                      .round(),
              onChanged: (v) => viewModel.previewFontSize(v.round()),
              onChangeEnd: (v) => viewModel.updateFontSize(v.round()),
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
            ),
            _Divider(isDark: isDark),
            _SliderRow(
              label: AppStrings.settingsFocusWindowLabel.tr,
              value: prefs.focusWindowLines.toDouble(),
              displayValue: AppStrings.settingsFocusWindowValue.trParams({
                'n': '${prefs.focusWindowLines}',
              }),
              min: 1,
              max: AppConstants.maxFocusLines.toDouble(),
              divisions: AppConstants.maxFocusLines - 1,
              onChanged: (v) => viewModel.previewFocusLines(v.round()),
              onChangeEnd: (v) => viewModel.updateFocusLines(v.round()),
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slider row ────────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final String displayValue;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color onSurface;
  final Color onSurfaceVariant;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.onChangeEnd,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                displayValue,
                style: AppTypography.labelMedium.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ],
      ),
    );
  }
}

// ── Thin divider ─────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
          .withValues(alpha: 0.3),
    );
  }
}
