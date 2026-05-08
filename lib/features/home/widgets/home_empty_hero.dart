import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class HomeEmptyHero extends StatelessWidget {
  final VoidCallback onImport;

  const HomeEmptyHero({super.key, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.glassBackground(isDark),
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: AppColors.glassBorder(isDark)),
            ),
            child: Column(
              children: [
                // Illustration zone
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 40,
                      color: primaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // Text + CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.homeEmptyHeadline.tr,
                        textAlign: TextAlign.center,
                        style: AppTypography.homeEmptyTitle.copyWith(
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppStrings.homeEmptyBody.tr,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Glass CTA button
                      TapScale(
                        onTap: onImport,
                        child: ClipRRect(
                          borderRadius: AppRadius.mdBorder,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.smd,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.glassInner(isDark),
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(
                                  color: AppColors.glassBorder(isDark),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                AppStrings.homeImportPdf.tr,
                                style: AppTypography.homeCtaLabel.copyWith(
                                  color: onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
