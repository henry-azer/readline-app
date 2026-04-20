import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightSurface,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      secondary: AppColors.lightTertiary,
      tertiary: AppColors.lightTertiary,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      surface: AppColors.lightSurfaceContainer,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outlineVariant: AppColors.lightOutlineVariant,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: AppColors.transparent,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.lightOnSurface,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightOnSurface),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        textStyle: AppTypography.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        textStyle: AppTypography.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        side: BorderSide(
          color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.lightOutlineVariant.withValues(alpha: 0.15),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightSurfaceContainerHigh,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightOnSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.tertiary,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      surface: AppColors.surfaceContainer,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outlineVariant: AppColors.outlineVariant,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: AppColors.transparent,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.onSurface,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: AppTypography.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        textStyle: AppTypography.button,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.outlineVariant.withValues(alpha: 0.15),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceContainerHigh,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
