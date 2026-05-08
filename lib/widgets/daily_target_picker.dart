import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/sheet_handle.dart';
import 'package:readline_app/widgets/target_chip.dart';

/// Preset daily target values in minutes.
const _presets = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];

class DailyTargetPicker extends StatelessWidget {
  final int currentMinutes;
  final ValueChanged<int> onTargetSelected;

  const DailyTargetPicker({
    super.key,
    required this.currentMinutes,
    required this.onTargetSelected,
  });

  /// Shows the picker as a modal bottom sheet and returns the selected value,
  /// or null if dismissed without selecting.
  static Future<int?> show(
    BuildContext context, {
    required int currentMinutes,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => DailyTargetPicker(
        currentMinutes: currentMinutes,
        onTargetSelected: (value) {
          getIt<HapticService>().selection();
          Navigator.of(sheetContext).pop(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              const SizedBox(height: AppSpacing.lg),

              Text(
                AppStrings.homeSetDailyTarget.tr,
                style: AppTypography.dailyTargetTitle.copyWith(
                  color: onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),

              Text(
                AppStrings.homeSetDailyTargetSubtitle.tr,
                style: AppTypography.bodyMedium.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _presets.map((minutes) {
                  return TargetChip(
                    minutes: minutes,
                    isSelected: minutes == currentMinutes,
                    primaryColor: primaryColor,
                    onSurfaceVariant: onSurfaceVariant,
                    isDark: isDark,
                    onTap: () => onTargetSelected(minutes),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
