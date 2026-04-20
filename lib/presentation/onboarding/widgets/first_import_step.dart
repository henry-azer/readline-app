import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/widgets/read_it_button.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class FirstImportStep extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onChooseFromFiles;
  final VoidCallback onSampleText;
  final VoidCallback onSkip;

  const FirstImportStep({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.onChooseFromFiles,
    required this.onSampleText,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final dropZoneBg = isDark
        ? AppColors.surfaceContainerLow
        : const Color(0xFFBEA9A4); // muted rose-brown from design

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Headline
            Text(
              AppStrings.onboardingImportHeadline.tr,
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium.copyWith(
                color: onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              AppStrings.onboardingImportSubtitle.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Drop zone
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: dropZoneBg,
                borderRadius: AppRadius.lgBorder,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Upload icon circle
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.upload_outlined,
                          size: 28,
                          color: AppColors.lightOnSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppStrings.onboardingDropFiles.tr,
                        style: AppTypography.label.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariant
                              : AppColors.lightSurfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        AppStrings.onboardingDropFilesSupport.tr,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariant
                              : AppColors.lightSurfaceContainerHighest,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  // OCR badge
                  Positioned(
                    bottom: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.smBorder,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: const Color(0xFFB44B3C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.onboardingOcrEnhanced.tr,
                            style: AppTypography.label.copyWith(
                              color: AppColors.lightOnSurface,
                              fontSize: 9,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Error message
            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.error : AppColors.lightError,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // CHOOSE FROM FILES primary CTA
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primary,
                      strokeWidth: 2,
                    ),
                  )
                : ReadItButton(
                    label: AppStrings.onboardingChooseFromFiles.tr,
                    icon: Icons.folder_outlined,
                    onTap: onChooseFromFiles,
                  ),
            const SizedBox(height: AppSpacing.md),

            // TRY WITH SAMPLE TEXT secondary
            ReadItButton(
              label: AppStrings.onboardingTrySampleText.tr,
              isSecondary: true,
              onTap: isLoading ? null : onSampleText,
            ),
            const SizedBox(height: AppSpacing.xl),

            // SKIP FOR NOW text link
            Center(
              child: TapScale(
                onTap: isLoading ? null : onSkip,
                child: Text(
                  AppStrings.onboardingSkipForNow.tr,
                  style: AppTypography.label.copyWith(color: onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
