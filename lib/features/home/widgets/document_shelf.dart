import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/data/utils/document_sort.dart';
import 'package:readline_app/features/home/widgets/shelf_card.dart';

class DocumentShelf extends StatelessWidget {
  final List<DocumentModel> documents;
  final String? currentDocId;
  final VoidCallback? onReturn;
  final int avgWpm;
  final int savedWpm;

  /// Map of document id → total minutes the user actually spent reading it
  /// (sum of session durations). Looked up per card so completed shelf
  /// items show real time spent instead of a WPM projection.
  final Map<String, double> actualMinutesByDoc;

  const DocumentShelf({
    super.key,
    required this.documents,
    this.currentDocId,
    this.onReturn,
    required this.avgWpm,
    required this.savedWpm,
    this.actualMinutesByDoc = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    // Same tri-tier "smart" sort the library uses, so the home shelf and
    // library list always agree on ordering.
    final others = documents.where((d) => d.id != currentDocId).toList();
    sortDocumentsSmart(others);

    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            AppStrings.homeYourLibrary.tr,
            style: AppTypography.homeEyebrowLabel.copyWith(
              color: onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: others.length.clamp(0, 10),
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              return ShelfCard(
                document: others[index],
                onReturn: onReturn,
                avgWpm: avgWpm,
                savedWpm: savedWpm,
                actualMinutes: actualMinutesByDoc[others[index].id],
              );
            },
          ),
        ),
      ],
    );
  }
}
