import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:read_it/presentation/onboarding/widgets/level_card.dart';
import 'package:read_it/presentation/widgets/read_it_button.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class AssessmentStep extends StatelessWidget {
  final String selectedLevel;
  final void Function(String levelId) onSelectLevel;
  final VoidCallback onContinue;
  final VoidCallback onCustomizeLater;

  const AssessmentStep({
    super.key,
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
                // Logo
                Text(
                  AppStrings.onboardingAssessmentLogo.tr,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark ? AppColors.primary : AppColors.lightPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Headline
                Text(
                  AppStrings.onboardingAssessmentHeadline.tr,
                  style: AppTypography.displayMedium.copyWith(color: onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Subtitle
                Text(
                  AppStrings.onboardingAssessmentSubtitle.tr,
                  style: AppTypography.bodyLarge.copyWith(
                    color: onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Scrollable level cards
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: readingLevels.length,
              separatorBuilder: (ctx, idx) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final level = readingLevels[index];
                return LevelCard(
                  level: level,
                  isSelected: selectedLevel == level.id,
                  onTap: () => onSelectLevel(level.id),
                );
              },
            ),
          ),

          // Bottom actions
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
                ReadItButton(
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
