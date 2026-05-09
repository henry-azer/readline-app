import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/vocabulary/widgets/review_i_know_this_button.dart';
import 'package:readline_app/features/vocabulary/widgets/review_still_learning_button.dart';

/// Pair of "Still Learning" / "I Know This" buttons shown after a flashcard
/// is flipped. Triggers haptic feedback before forwarding the tap.
class ReviewActionButtons extends StatelessWidget {
  final Future<void> Function() onMastered;
  final Future<void> Function() onLearning;

  const ReviewActionButtons({
    super.key,
    required this.onMastered,
    required this.onLearning,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: ReviewStillLearningButton(
              isDark: isDark,
              onTap: () {
                getIt<HapticService>().light();
                onLearning();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ReviewIKnowThisButton(
              isDark: isDark,
              onTap: () {
                getIt<HapticService>().light();
                onMastered();
              },
            ),
          ),
        ],
      ),
    );
  }
}
