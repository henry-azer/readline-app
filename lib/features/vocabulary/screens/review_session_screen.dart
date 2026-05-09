import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/viewmodels/review_session_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/review_no_words_view.dart';
import 'package:readline_app/features/vocabulary/widgets/review_session_view.dart';
import 'package:readline_app/features/vocabulary/widgets/review_summary_view.dart';

/// Full-screen flashcard review session.
///
/// - Shows word on front, context + definition on back
/// - "I Know This" (mastered) and "Still Learning" buttons
/// - Progress bar showing position in session
/// - Summary screen at the end
class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  late final ReviewSessionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReviewSessionViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          builder: (context, loadingSnap) {
            if (loadingSnap.data == true) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.primary : AppColors.lightPrimary,
                ),
              );
            }

            return StreamBuilder<bool>(
              stream: _viewModel.isComplete$,
              builder: (context, completeSnap) {
                if (completeSnap.data == true) {
                  return ReviewSummaryView(
                    viewModel: _viewModel,
                    onClose: () => context.pop(),
                  );
                }

                return StreamBuilder<List<VocabularyWordModel>>(
                  stream: _viewModel.words$,
                  builder: (context, wordsSnap) {
                    final words = wordsSnap.data ?? const [];

                    if (words.isEmpty) {
                      return ReviewNoWordsView(onClose: () => context.pop());
                    }

                    return ReviewSessionView(viewModel: _viewModel);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
