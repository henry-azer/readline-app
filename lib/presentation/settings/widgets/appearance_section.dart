import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/user_preferences_model.dart';
import 'package:read_it/presentation/settings/viewmodels/settings_viewmodel.dart';

class AppearanceSection extends StatelessWidget {
  final SettingsViewModel viewModel;
  final UserPreferencesModel prefs;

  const AppearanceSection({
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
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final dividerColor =
        (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
            .withValues(alpha: 0.3);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme mode row
          Text(
            AppStrings.settingsThemeMode.tr,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleGroup(
            options: [
              AppStrings.settingsThemeLight.tr,
              AppStrings.settingsThemeDark.tr,
              AppStrings.settingsThemeSystem.tr,
            ],
            values: const ['light', 'dark', 'system'],
            selected: prefs.themeMode,
            onSelected: viewModel.updateThemeMode,
            isDark: isDark,
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, thickness: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.md),

          // Font family row
          Text(
            AppStrings.settingsFontFamily.tr,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ToggleGroup(
            options: [
              AppStrings.settingsFontInter.tr,
              AppStrings.settingsFontLiterata.tr,
              AppStrings.settingsFontNewsreader.tr,
            ],
            values: const ['inter', 'literata', 'newsreader'],
            selected: prefs.fontFamily,
            onSelected: viewModel.updateFontFamily,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ── Toggle group (pill chips) ─────────────────────────────────────────────────

class _ToggleGroup extends StatelessWidget {
  final List<String> options;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isDark;

  const _ToggleGroup({
    required this.options,
    required this.values,
    required this.selected,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onPrimary = isDark ? AppColors.onPrimary : AppColors.lightOnPrimary;
    final chipBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final chipText = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = values[i] == selected;
        return Padding(
          padding: EdgeInsets.only(
            right: i < options.length - 1 ? AppSpacing.xs : 0,
          ),
          child: GestureDetector(
            onTap: () => onSelected(values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primary : chipBg,
                borderRadius: AppRadius.fullBorder,
                border: isSelected
                    ? null
                    : Border.all(
                        color:
                            (isDark
                                    ? AppColors.outlineVariant
                                    : AppColors.lightOutlineVariant)
                                .withValues(alpha: 0.4),
                        width: 1,
                      ),
              ),
              child: Text(
                options[i],
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? onPrimary : chipText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
