import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/widgets/no_search_results.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_empty_state.dart';
import 'package:readline_app/features/vocabulary/widgets/word_card.dart';

/// Scrollable list of vocabulary words. Renders an empty/no-results state
/// when [words] is empty, or a stack of [WordCard]s otherwise.
class VocabularyWordList extends StatelessWidget {
  final List<VocabularyWordModel> words;
  final Set<String> expanded;
  final String searchQuery;
  final bool isDark;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<VocabularyWordModel> onDelete;
  final ValueChanged<String> onCycleDifficulty;

  const VocabularyWordList({
    super.key,
    required this.words,
    required this.expanded,
    required this.searchQuery,
    required this.isDark,
    required this.onToggleExpanded,
    required this.onDelete,
    required this.onCycleDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    // Extra room beneath the last card so the shell's bottom nav doesn't
    // visually overlap the difficulty pill on the final word.
    const bottomPadding = AppSpacing.bottomNavClearance + AppSpacing.xxl;

    if (words.isEmpty && searchQuery.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: bottomPadding),
        children: [VocabNoSearchResults(isDark: isDark)],
      );
    }
    if (words.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: bottomPadding),
        children: [VocabularyEmptyState(isDark: isDark)],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        bottomPadding,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: WordCard(
            word: word,
            isExpanded: expanded.contains(word.id),
            onTap: () => onToggleExpanded(word.id),
            onDelete: () => onDelete(word),
            onDifficultyTap: () => onCycleDifficulty(word.id),
          ),
        );
      },
    );
  }
}
