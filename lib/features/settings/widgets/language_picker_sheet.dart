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

class LanguagePickerSheet extends StatelessWidget {
  final SettingsViewModel viewModel;

  const LanguagePickerSheet({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, SettingsViewModel viewModel) {
    final isDark = context.isDark;
    final sheetBg = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => LanguagePickerSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final labelColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return StreamBuilder<String?>(
      stream: viewModel.selectedLocale$,
      builder: (context, snap) {
        final locale = snap.data;
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
                  AppStrings.settingsLanguage.tr,
                  style: AppTypography.settingsEyebrow.copyWith(
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SettingsPickerOption(
                  leading: Icon(
                    Icons.language_outlined,
                    size: 20,
                    color: labelColor,
                  ),
                  label: AppStrings.settingsSystemDefault.tr,
                  isSelected: locale == null,
                  onTap: () {
                    viewModel.saveLocale(null);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: AppSpacing.xxs),
                for (final lang in viewModel.availableLanguages) ...[
                  SettingsPickerOption(
                    leading: Text(
                      lang.flagEmoji,
                      style: AppTypography.settingsLanguageFlag,
                    ),
                    label: lang.nativeName,
                    isSelected: locale == lang.code,
                    onTap: () {
                      viewModel.saveLocale(lang.code);
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
}
