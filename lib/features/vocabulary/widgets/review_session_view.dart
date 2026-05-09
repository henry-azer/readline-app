import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/vocabulary/viewmodels/review_session_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/review_action_buttons.dart';
import 'package:readline_app/features/vocabulary/widgets/review_flash_card.dart';
import 'package:readline_app/features/vocabulary/widgets/review_flip_hint.dart';
import 'package:readline_app/features/vocabulary/widgets/review_session_header.dart';

/// In-session view: header + flashcard + flip hint or action buttons.
class ReviewSessionView extends StatelessWidget {
  final ReviewSessionViewModel viewModel;

  const ReviewSessionView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: viewModel.currentIndex$,
      builder: (context, indexSnap) {
        return StreamBuilder<bool>(
          stream: viewModel.isFlipped$,
          builder: (context, flippedSnap) {
            final currentIndex = indexSnap.data ?? 0;
            final isFlipped = flippedSnap.data ?? false;
            final totalWords = viewModel.words.length;
            final word = viewModel.currentWord;

            if (word == null) return const SizedBox.shrink();

            final progress = totalWords > 0 ? currentIndex / totalWords : 0.0;

            return Column(
              children: [
                ReviewSessionHeader(
                  currentIndex: currentIndex,
                  totalWords: totalWords,
                  progress: progress,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: ReviewFlashCard(
                      word: word,
                      isFlipped: isFlipped,
                      onFlip: viewModel.flipCard,
                    ),
                  ),
                ),

                AnimatedSwitcher(
                  duration: AppDurations.normal,
                  child: isFlipped
                      ? ReviewActionButtons(
                          key: const ValueKey<String>('actions'),
                          onMastered: viewModel.markMastered,
                          onLearning: viewModel.markLearning,
                        )
                      : ReviewFlipHint(
                          key: const ValueKey<String>('flip-hint'),
                          onTap: viewModel.flipCard,
                        ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        );
      },
    );
  }
}
