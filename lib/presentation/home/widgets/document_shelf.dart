import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/library/utils/open_document.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class DocumentShelf extends StatelessWidget {
  final List<DocumentModel> documents;
  final String? currentDocId;
  final VoidCallback? onReturn;

  const DocumentShelf({
    super.key,
    required this.documents,
    this.currentDocId,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    // Filter out current document, show remaining sorted by last read
    final others = documents.where((d) => d.id != currentDocId).toList()
      ..sort((a, b) {
        final aDate = a.lastReadAt ?? a.importedAt;
        final bDate = b.lastReadAt ?? b.importedAt;
        return bDate.compareTo(aDate);
      });

    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            AppStrings.homeYourLibrary.tr,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant.withValues(alpha: 0.6),
              letterSpacing: 2,
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Horizontal scroll
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: others.length.clamp(0, 10),
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              return _ShelfCard(document: others[index], onReturn: onReturn);
            },
          ),
        ),
      ],
    );
  }
}

class _ShelfCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onReturn;

  const _ShelfCard({required this.document, this.onReturn});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final progress = document.totalWords > 0
        ? (document.wordsRead / document.totalWords).clamp(0.0, 1.0)
        : 0.0;
    final iconColors = [primaryColor, AppColors.streakGradientStart];
    final docIndex = document.id.hashCode.abs();
    final iconColor = iconColors[docIndex % iconColors.length];

    return TapScale(
      onTap: () async {
        await openDocumentForReading(context, document);
        onReturn?.call();
      },
      child: ClipRRect(
        borderRadius: AppRadius.mdBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 148,
            padding: const EdgeInsets.all(AppSpacing.smd),
            decoration: BoxDecoration(
              color: AppColors.glassBackground(isDark),
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: AppColors.glassBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: AppRadius.smdBorder,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: iconColor,
                  ),
                ),
                const Spacer(),
                Text(
                  document.title.isNotEmpty
                      ? document.title
                      : document.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: onSurface,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.sxs),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.glassTrack(isDark),
                    borderRadius: AppRadius.xsBorder,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.4),
                        borderRadius: AppRadius.xsBorder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppStrings.homePagesProgress.trParams({
                    'current': '${document.currentPage}',
                    'total': '${document.totalPages}',
                  }),
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                    fontSize: 10,
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
