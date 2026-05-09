import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/core/utils/date_formatter.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/utils/open_document.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class ShelfCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onReturn;
  final int avgWpm;
  final int savedWpm;

  /// Total minutes the user actually spent reading this document (sum of
  /// session durations). Used for completed-doc cards to show real time
  /// spent instead of a WPM projection.
  final double? actualMinutes;

  const ShelfCard({
    super.key,
    required this.document,
    this.onReturn,
    required this.avgWpm,
    required this.savedWpm,
    this.actualMinutes,
  });

  ({String label, Color color, IconData? icon})? _statusBadge(bool isDark) {
    if (document.isCompleted) {
      return (
        label: AppStrings.homeShelfStatusCompleted.tr,
        color: isDark ? AppColors.success : AppColors.lightSuccess,
        icon: Icons.check_rounded,
      );
    }
    if (document.isInProgress) {
      return (
        label: AppStrings.homeShelfStatusContinue.tr,
        color: isDark ? AppColors.primary : AppColors.lightPrimary,
        icon: Icons.play_arrow_rounded,
      );
    }
    return null;
  }

  String _metaText() {
    // Completed docs: show what the user actually spent reading (sum of
    // sessions) rather than a projection.
    if (document.isCompleted &&
        actualMinutes != null &&
        actualMinutes! > 0) {
      return DateFormatter.duration(actualMinutes!);
    }

    if (document.totalWords <= 0) return '';

    final wpm = savedWpm > 0 ? savedWpm : avgWpm;

    if (document.isInProgress) {
      final wordsLeft = document.totalWords - document.wordsRead;
      if (wordsLeft <= 0 || wpm <= 0) return '';
      final mins = (wordsLeft / wpm).ceil();
      if (mins <= 0) return '';
      return AppStrings.homeEstimatedLeft.trParams({'n': '$mins'});
    }

    if (wpm <= 0) return '';
    final mins = (document.totalWords / wpm).ceil();
    if (mins <= 0) return '';
    return AppStrings.homeEstimatedTotal.trParams({'n': '$mins'});
  }

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
    final badge = _statusBadge(isDark);
    final metaText = _metaText();

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: AppRadius.smdBorder,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                    const Spacer(),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badge.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.fullBorder,
                          border: Border.all(
                            color: badge.color.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (badge.icon != null) ...[
                              Icon(
                                badge.icon,
                                size: 10,
                                color: badge.color,
                              ),
                              const SizedBox(width: 2),
                            ],
                            Text(
                              badge.label,
                              style: AppTypography.homeProgressMicroLabel
                                  .copyWith(color: badge.color),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  document.title.isNotEmpty
                      ? document.title
                      : document.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.homeShelfMeta.copyWith(color: onSurface),
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
                if (metaText.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    metaText,
                    style: AppTypography.homeBadgeLabel.copyWith(
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
