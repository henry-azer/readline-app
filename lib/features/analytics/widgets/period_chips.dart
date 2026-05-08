import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/analytics/viewmodels/analytics_viewmodel.dart';

class PeriodChips extends StatelessWidget {
  final VolumePeriod selectedPeriod;
  final ValueChanged<VolumePeriod> onPeriodChanged;
  final bool isDark;

  const PeriodChips({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      (VolumePeriod.days7, AppStrings.analyticsPeriod7d.tr),
      (VolumePeriod.days30, AppStrings.analyticsPeriod30d.tr),
      (VolumePeriod.days90, AppStrings.analyticsPeriod90d.tr),
      (VolumePeriod.allTime, AppStrings.analyticsPeriodAll.tr),
    ];

    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final chipBg = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;

    return Row(
      children: periods.map((p) {
        final isSelected = p.$1 == selectedPeriod;
        final style = isSelected
            ? AppTypography.analyticsPeriodChipSelected
            : AppTypography.analyticsPeriodChip;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: GestureDetector(
            onTap: () => onPeriodChanged(p.$1),
            child: AnimatedContainer(
              duration: AppDurations.short,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: isDark ? 0.2 : 0.12)
                    : chipBg,
                borderRadius: AppRadius.smBorder,
                border: isSelected
                    ? Border.all(color: primary.withValues(alpha: 0.4))
                    : null,
              ),
              child: Text(
                p.$2,
                style: style.copyWith(
                  color: isSelected ? primary : onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
