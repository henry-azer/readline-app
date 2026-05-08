import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/reading_level.dart';
import 'package:readline_app/features/onboarding/widgets/level_card.dart';
import 'package:readline_app/widgets/readline_button.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class AssessmentScreen extends StatelessWidget {
  final List<ReadingLevel> levels;
  final String selectedLevel;
  final void Function(String levelId) onSelectLevel;
  final VoidCallback onContinue;
  final VoidCallback onCustomizeLater;

  const AssessmentScreen({
    super.key,
    required this.levels,
    required this.selectedLevel,
    required this.onSelectLevel,
    required this.onContinue,
    required this.onCustomizeLater,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final hasSelection = selectedLevel.isNotEmpty;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xxxxl + AppSpacing.md),

                Text(
                  AppStrings.onboardingAssessmentHeadline.tr,
                  style: AppTypography.displayMedium.copyWith(color: onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),

                Text(
                  AppStrings.onboardingAssessmentSubtitle.tr,
                  style: AppTypography.onboardingSubtitleItalic.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.82,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return LevelCard(
                    level: level,
                    isSelected: selectedLevel == level.id,
                    onTap: () => onSelectLevel(level.id),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReadlineButton(
                  label: AppStrings.onboardingContinueJourney.tr,
                  onTap: hasSelection ? onContinue : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TapScale(
                    onTap: onCustomizeLater,
                    child: Text(
                      AppStrings.onboardingCustomizeLater.tr,
                      style: AppTypography.label.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
