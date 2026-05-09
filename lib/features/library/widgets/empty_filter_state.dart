import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class EmptyFilterState extends StatelessWidget {
  final String filter;
  final bool isDark;
  final String searchQuery;

  const EmptyFilterState({
    super.key,
    required this.filter,
    required this.isDark,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final (headline, subtext) = searchQuery.isNotEmpty
        ? (AppStrings.libraryNoSearchResults.tr, '')
        : switch (filter) {
            'reading' => (
              AppStrings.libraryEmptyReading.tr,
              AppStrings.libraryEmptyReadingBody.tr,
            ),
            'completed' => (
              AppStrings.libraryEmptyCompleted.tr,
              AppStrings.libraryEmptyCompletedBody.tr,
            ),
            'unread' => (
              AppStrings.libraryEmptyNotStarted.tr,
              AppStrings.libraryEmptyNotStartedBody.tr,
            ),
            _ => (
              AppStrings.libraryEmptyAll.tr,
              AppStrings.libraryEmptyAllBody.tr,
            ),
          };

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xxxl,
        right: AppSpacing.xxxl,
        top: AppSpacing.xxxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xxxxl),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color:
                  (isDark
                          ? AppColors.primaryContainer
                          : AppColors.lightPrimaryContainer)
                      .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.library_books_rounded,
              size: 56,
              color: onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            headline,
            style: AppTypography.headlineMedium.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtext,
              style: AppTypography.bodyMedium.copyWith(
                color: onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
