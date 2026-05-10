import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/viewmodels/review_session_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/review_no_words_view.dart';
import 'package:readline_app/features/vocabulary/widgets/review_session_view.dart';
import 'package:readline_app/features/vocabulary/widgets/review_summary_dialog.dart';

/// Full-screen flashcard review session.
///
/// - Shows word on front, context + definition on back
/// - "I Know This" (mastered) and "Still Learning" buttons
/// - Progress bar showing position in session
/// - Completion popup shown over the last card when the session ends
class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  late final ReviewSessionViewModel _viewModel;
  StreamSubscription<ReviewSessionResults>? _summarySub;

  @override
  void initState() {
    super.initState();
    _viewModel = ReviewSessionViewModel();
    _viewModel.init();
    _summarySub = _viewModel.summaryReady$.listen(_onSummaryReady);
  }

  @override
  void dispose() {
    _summarySub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSummaryReady(ReviewSessionResults results) {
    if (!mounted) return;
    _showSummaryDialog(results);
  }

  Future<void> _showSummaryDialog(ReviewSessionResults results) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.barrierOverlay,
      builder: (dialogContext) => ReviewSummaryDialog(
        results: results,
        onDone: () => Navigator.of(dialogContext).pop(),
      ),
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
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
        ),
      ),
    );
  }
}
