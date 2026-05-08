import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/reading/viewmodels/reading_viewmodel.dart';

/// In-stack top bar for the reading screen — replaces the Scaffold's appBar
/// so it lives inside the reading body Stack and the popup scrim can render
/// *above* the action buttons.
class ReadingTopBar extends StatelessWidget {
  final ReadingViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onShowSettings;

  const ReadingTopBar({
    super.key,
    required this.viewModel,
    required this.onBack,
    required this.onShowSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: onSurfaceVariant,
              size: 20,
            ),
            onPressed: onBack,
            tooltip: AppStrings.readingBack.tr,
          ),
          Expanded(
            child: StreamBuilder<DocumentModel?>(
              stream: viewModel.document$,
              builder: (context, snap) {
                final doc = snap.data;
                return Text(
                  doc?.title ?? '',
                  style: AppTypography.labelMedium.copyWith(
                    color: onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: onSurfaceVariant,
              size: 18,
            ),
            onPressed: onShowSettings,
          ),
        ],
      ),
    );
  }
}
