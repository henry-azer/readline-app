import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:readline_app/features/settings/widgets/settings_picker_option.dart';

class ThemePickerSheet extends StatelessWidget {
  final SettingsViewModel viewModel;

  const ThemePickerSheet({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, SettingsViewModel viewModel) {
    final isDark = context.isDark;
    final sheetBg = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ThemePickerSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final labelColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return StreamBuilder<String>(
      stream: viewModel.themeMode$,
      builder: (context, snap) {
        final selected = snap.data ?? 'system';
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.settingsTheme.tr,
                  style: AppTypography.settingsEyebrow.copyWith(
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final option in const [
                  ('system', Icons.settings_suggest_outlined),
                  ('dark', Icons.dark_mode_outlined),
                  ('light', Icons.light_mode_outlined),
                ]) ...[
                  SettingsPickerOption(
                    leading: Icon(option.$2, size: 20, color: labelColor),
                    label: _labelFor(option.$1),
                    isSelected: selected == option.$1,
                    onTap: () {
                      viewModel.saveThemeMode(option.$1);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _labelFor(String mode) {
    return switch (mode) {
      'dark' => AppStrings.settingsThemeDark.tr,
      'light' => AppStrings.settingsThemeLight.tr,
      _ => AppStrings.settingsSystemDefault.tr,
    };
  }
}
