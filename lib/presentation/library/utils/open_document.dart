import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/document_model.dart';

/// Navigates to the reading screen for [doc]. If the document is already
/// completed, asks the user whether to read it again from the beginning;
/// only restarts on confirm.
Future<void> openDocumentForReading(
  BuildContext context,
  DocumentModel doc,
) async {
  if (!doc.isCompleted) {
    await context.push('${AppRoutes.reading}/${doc.id}');
    return;
  }

  final confirmed = await _confirmReadAgain(context, doc);
  if (!context.mounted || confirmed != true) return;
  await context.push('${AppRoutes.reading}/${doc.id}?restart=true');
}

Future<bool?> _confirmReadAgain(BuildContext context, DocumentModel doc) {
  final isDark = context.isDark;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark
          ? AppColors.surfaceContainerHigh
          : AppColors.lightSurfaceContainerLowest,
      title: Text(
        AppStrings.homeReadAgain.tr,
        style: AppTypography.titleMedium.copyWith(
          color: isDark ? AppColors.onSurface : AppColors.lightOnSurface,
        ),
      ),
      content: Text(
        AppStrings.homeReadAgainBody.trParams({
          'title': doc.title.isEmpty ? doc.fileName : doc.title,
        }),
        style: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.onSurfaceVariant
              : AppColors.lightOnSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            AppStrings.cancel.tr,
            style: AppTypography.button.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            AppStrings.homeReadAgainLabel.tr,
            style: AppTypography.button.copyWith(
              color: isDark ? AppColors.primary : AppColors.lightPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
