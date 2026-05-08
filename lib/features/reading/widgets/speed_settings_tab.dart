import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class SpeedSettingsTab extends StatelessWidget {
  final int speed;
  final bool isDark;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color trackColor;
  final ValueChanged<int> onSpeedChanged;

  const SpeedSettingsTab({
    super.key,
    required this.speed,
    required this.isDark,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.onSpeedChanged,
  });

  static const _presets = <({String labelKey, int value})>[
    (labelKey: 'player.speedPresetSlow', value: 100),
    (labelKey: 'player.speedPresetNormal', value: 200),
    (labelKey: 'player.speedPresetFast', value: 350),
    (labelKey: 'player.speedPresetSpeed', value: 500),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          // ── Large speed display ──────────────────────────────────────
          Text(
            '$speed',
            style: AppTypography.readingHeroValue.copyWith(color: onSurface),
          ),
          Text(
            AppStrings.readingWpm.tr,
            style: AppTypography.readingHeroUnit.copyWith(
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Speed slider ────────────────────────────────────────────
          Slider(
            value: speed.toDouble(),
            min: AppConstants.minWpm.toDouble(),
            max: AppConstants.maxWpm.toDouble(),
            divisions:
                ((AppConstants.maxWpm - AppConstants.minWpm) /
                        AppConstants.wpmStep)
                    .round(),
            onChanged: (v) => onSpeedChanged(v.round()),
          ),

          // ── Range labels ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppConstants.minWpm}',
                  style: AppTypography.analyticsAxisTick.copyWith(
                    color: onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '${AppConstants.maxWpm}',
                  style: AppTypography.analyticsAxisTick.copyWith(
                    color: onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Preset chips ────────────────────────────────────────────
          Row(
            children: _presets.map((preset) {
              final isActive = speed == preset.value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () {
                      getIt<HapticService>().light();
                      onSpeedChanged(preset.value);
                    },
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary.withValues(alpha: 0.12)
                            : trackColor,
                        borderRadius: AppRadius.smBorder,
                        border: Border.all(
                          color: isActive ? primary : AppColors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${preset.value}',
                            style: AppTypography.readingValueDisplay.copyWith(
                              color: isActive ? primary : onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.micro),
                          Text(
                            preset.labelKey.tr,
                            style: AppTypography.readingTinyLabel.copyWith(
                              color: isActive ? primary : onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
