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

class AdvancedSection extends StatelessWidget {
  final SettingsViewModel viewModel;
  final UserPreferencesModel prefs;

  const AdvancedSection({
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
    final dividerColor =
        (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
            .withValues(alpha: 0.3);

    return Column(
      children: [
        // Toggles card
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.lgBorder,
          ),
          child: Column(
            children: [
              _ToggleTile(
                icon: Icons.book_outlined,
                title: AppStrings.settingsVocabCollection.tr,
                subtitle: AppStrings.settingsVocabCollectionSubtitle.tr,
                value: prefs.enableVocabCollection,
                onChanged: (_) => viewModel.toggleVocabCollection(),
                isDark: isDark,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),
              _ToggleTile(
                icon: Icons.show_chart_rounded,
                title: AppStrings.settingsReadingAnalytics.tr,
                subtitle: AppStrings.settingsReadingAnalyticsSubtitle.tr,
                value: prefs.enableAnalytics,
                onChanged: (_) => viewModel.toggleAnalytics(),
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Reset to defaults button
        _ResetButton(viewModel: viewModel, isDark: isDark),

        const SizedBox(height: AppSpacing.sm),

        // App version info
        _AppVersionInfo(isDark: isDark),
      ],
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceContainerHigh
                  : AppColors.lightSurfaceContainerHigh,
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(icon, color: onSurfaceVariant, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: onSurface,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: primary,
            activeTrackColor: primary.withValues(alpha: 0.3),
            inactiveThumbColor: onSurfaceVariant,
            inactiveTrackColor: (isDark
                ? AppColors.surfaceContainerHighest
                : AppColors.lightSurfaceContainerHighest),
          ),
        ],
      ),
    );
  }
}

// ── Reset button ─────────────────────────────────────────────────────────────

class _ResetButton extends StatelessWidget {
  final SettingsViewModel viewModel;
  final bool isDark;

  const _ResetButton({required this.viewModel, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirmReset(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: Text(
          AppStrings.settingsResetButton.tr,
          style: AppTypography.button.copyWith(
            color: primary,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final dialogBg = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerLowest;

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        title: Text(
          AppStrings.settingsResetTitle.tr,
          style: AppTypography.headlineMedium.copyWith(
            color: onSurface,
            fontSize: 18,
          ),
        ),
        content: Text(
          AppStrings.settingsResetBody.tr,
          style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppStrings.settingsResetCancel.tr,
              style: AppTypography.button.copyWith(
                color: onSurfaceVariant,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              viewModel.resetToDefaults();
            },
            child: Text(
              AppStrings.settingsResetConfirm.tr,
              style: AppTypography.button.copyWith(
                color: primary,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App version info ──────────────────────────────────────────────────────────

class _AppVersionInfo extends StatelessWidget {
  final bool isDark;
  const _AppVersionInfo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        AppStrings.settingsVersionInfo.tr,
        style: AppTypography.bodySmall.copyWith(
          color: onSurfaceVariant,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
