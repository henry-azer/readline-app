import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/readline_button.dart';

class MagicContentKeyCard extends StatelessWidget {
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggleObscured;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTest;
  final VoidCallback? onSave;
  final bool isBusy;
  final VoidCallback? onClear;

  const MagicContentKeyCard({
    super.key,
    required this.controller,
    required this.obscured,
    required this.onToggleObscured,
    required this.enabled,
    required this.onChanged,
    required this.onTest,
    required this.onSave,
    required this.isBusy,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final border =
        (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
            .withValues(alpha: 0.4);
    final hintColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final textColor = isDark
        ? AppColors.onSurface
        : AppColors.lightOnSurface;
    final fillColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final disabledOpacity = enabled ? 1.0 : 0.45;
    final canTap = enabled && !isBusy;

    return Opacity(
      opacity: disabledOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.magicSettingsKeyHelp.tr,
              style: AppTypography.bodySmall.copyWith(color: hintColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              obscureText: obscured,
              enabled: enabled,
              onChanged: onChanged,
              style: AppTypography.bodyMedium.copyWith(color: textColor),
              decoration: InputDecoration(
                hintText: AppStrings.magicSettingsKeyHint.tr,
                hintStyle: AppTypography.bodyMedium.copyWith(color: hintColor),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.smd,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide(color: primary),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: BorderSide(color: border),
                ),
                suffixIcon: IconButton(
                  tooltip: obscured
                      ? AppStrings.magicSettingsKeyShow.tr
                      : AppStrings.magicSettingsKeyHide.tr,
                  icon: Icon(
                    obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: hintColor,
                  ),
                  onPressed: enabled ? onToggleObscured : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isBusy) ...[
              ClipRRect(
                borderRadius: AppRadius.smBorder,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: fillColor,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasContent = value.text.trim().isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReadlineButton(
                      label: AppStrings.magicSettingsTestButton.tr,
                      isSecondary: true,
                      onTap: (canTap && hasContent) ? onTest : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ReadlineButton(
                      label: AppStrings.magicSettingsSaveButton.tr,
                      icon: Icons.lock_outline_rounded,
                      onTap: (canTap && hasContent) ? onSave : null,
                    ),
                  ],
                );
              },
            ),
            if (onClear != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: enabled ? onClear : null,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                  foregroundColor: isDark
                      ? AppColors.error
                      : AppColors.lightError,
                ),
                child: Text(
                  AppStrings.magicSettingsClearButton.tr,
                  style: AppTypography.button.copyWith(
                    color: isDark ? AppColors.error : AppColors.lightError,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
