import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/reading/widgets/theme_slider_row.dart';

class ThemeSettingsTab extends StatelessWidget {
  final String readingTheme;
  final double brightness;
  final double dim;
  final bool isDark;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color trackColor;
  final ValueChanged<String> onReadingThemeChanged;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onDimChanged;

  const ThemeSettingsTab({
    super.key,
    required this.readingTheme,
    required this.brightness,
    required this.dim,
    required this.isDark,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.onReadingThemeChanged,
    required this.onBrightnessChanged,
    required this.onDimChanged,
  });

  static const _themes = <({String id, String labelKey, Color? bg, Color? fg})>[
    (id: 'system', labelKey: 'player.readingThemeSystem', bg: null, fg: null),
    (
      id: 'light',
      labelKey: 'player.readingThemeLight',
      bg: AppColors.readingThemeLightBg,
      fg: AppColors.readingThemeLightFg,
    ),
    (
      id: 'dark',
      labelKey: 'player.readingThemeDark',
      bg: AppColors.readingThemeDarkBg,
      fg: AppColors.readingThemeDarkFg,
    ),
    (
      id: 'sepia',
      labelKey: 'player.readingThemeSepia',
      bg: AppColors.readingThemeSepiaBg,
      fg: AppColors.readingThemeSepiaFg,
    ),
    (
      id: 'amoled',
      labelKey: 'player.readingThemeAmoled',
      bg: AppColors.readingThemeAmoledBg,
      fg: AppColors.readingThemeAmoledFg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        Center(
          child: Text(
            AppStrings.playerReadingTheme.tr,
            style: AppTypography.readingSheetLabel.copyWith(
              color: onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // ── Theme swatches ──────────────────────────────────────────
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _themes.map((theme) {
              final isActive = readingTheme == theme.id;
              final isSystem = theme.id == 'system';
              final isLightBg =
                  (theme.bg?.computeLuminance() ?? (isDark ? 0.0 : 1.0)) > 0.5;
              final previewStyle = AppTypography.readingFont(
                'newsreader',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              );

              return GestureDetector(
                onTap: () {
                  getIt<HapticService>().light();
                  onReadingThemeChanged(theme.id);
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: AppDurations.normal,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSystem ? null : theme.bg,
                        shape: BoxShape.circle,
                        gradient: isSystem
                            ? const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [0.5, 0.5],
                                colors: [
                                  AppColors.readingThemeLightBg,
                                  AppColors.readingThemeDarkBg,
                                ],
                              )
                            : null,
                        border: Border.all(
                          color: isActive
                              ? primary
                              : isLightBg
                              ? AppColors.lightOutlineVariant
                              : AppColors.outlineVariant,
                          width: isActive ? 2.5 : 1,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isSystem
                            ? ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      stops: [0.5, 0.5],
                                      colors: [
                                        AppColors.readingThemeLightFg,
                                        AppColors.readingThemeDarkFg,
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  AppStrings.settingsReadingThemePreview.tr,
                                  style: previewStyle,
                                ),
                              )
                            : Text(
                                AppStrings.settingsReadingThemePreview.tr,
                                style: previewStyle.copyWith(color: theme.fg),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      theme.labelKey.tr,
                      style: (isActive
                              ? AppTypography.readingThemeChipActive
                              : AppTypography.readingThemeChip)
                          .copyWith(
                            color: isActive ? primary : onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Brightness slider (top-of-screen white overlay) ──────────────
        ThemeSliderRow(
          label: AppStrings.playerBrightness.tr,
          value: '${(brightness * 100).round()}%',
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          child: Slider(
            value: brightness.clamp(0.0, 1.0),
            onChanged: onBrightnessChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Dim slider (bottom-of-screen black overlay) ──────────────────
        ThemeSliderRow(
          label: AppStrings.playerDim.tr,
          value: '${(dim * 100).round()}%',
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          child: Slider(
            value: dim.clamp(0.0, 1.0),
            onChanged: onDimChanged,
          ),
        ),
      ],
    );
  }
}
