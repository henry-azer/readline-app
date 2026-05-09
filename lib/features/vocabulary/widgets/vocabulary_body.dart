import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/library/widgets/library_search_bar.dart';
import 'package:readline_app/features/vocabulary/viewmodels/vocabulary_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/review_bloom_card.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_filter_chips.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_word_list.dart';

/// Composes the vocabulary screen body: header, search, filter chips,
/// review bloom card, and word list. Pure presentation — sources its
/// state from streams on [VocabularyViewModel].
class VocabularyBody extends StatelessWidget {
  final VocabularyViewModel viewModel;
  final ValueChanged<VocabularyWordModel> onDelete;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchFieldTap;

  const VocabularyBody({
    super.key,
    required this.viewModel,
    required this.onDelete,
    required this.searchFocusNode,
    required this.onSearchFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return StreamBuilder<List<VocabularyWordModel>>(
      stream: viewModel.words$,
      builder: (context, wordsSnap) {
        return StreamBuilder<String>(
          stream: viewModel.activeFilter$,
          builder: (context, filterSnap) {
            return StreamBuilder<VocabularyStats>(
              stream: viewModel.stats$,
              builder: (context, statsSnap) {
                return StreamBuilder<Set<String>>(
                  stream: viewModel.expandedCards$,
                  builder: (context, expandedSnap) {
                    return StreamBuilder<String>(
                      stream: viewModel.searchQuery$,
                      builder: (context, searchSnap) {
                        final words = wordsSnap.data ?? const [];
                        final filter = filterSnap.data ?? 'all';
                        final stats = statsSnap.data ?? const VocabularyStats();
                        final expanded = expandedSnap.data ?? const {};
                        final searchQuery = searchSnap.data ?? '';

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                AppSpacing.md,
                                AppSpacing.xl,
                                AppSpacing.xs,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      AppStrings.vocabTitle.tr,
                                      style: AppTypography.displayMedium
                                          .copyWith(
                                            color: isDark
                                                ? AppColors.onSurface
                                                : AppColors.lightOnSurface,
                                          ),
                                    ),
                                  ),
                                  if (stats.total > 0) ...[
                                    const SizedBox(height: AppSpacing.xxs),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        AppStrings.vocabWordCount.trParams({
                                          'n': '${stats.total}',
                                        }),
                                        style: AppTypography.label.copyWith(
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: LibrarySearchBar(
                                onChanged: viewModel.setSearchQuery,
                                onClear: () => viewModel.setSearchQuery(''),
                                hintText: AppStrings.vocabSearchHint.tr,
                                focusNode: searchFocusNode,
                                onTap: onSearchFieldTap,
                              ),
                            ),

                            if (stats.total > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                  bottom: AppSpacing.md,
                                ),
                                child: VocabularyFilterChips(
                                  activeFilter: filter,
                                  onFilterChanged: viewModel.setFilter,
                                  stats: stats,
                                ),
                              ),

                            if (stats.dueForReview > 0)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  0,
                                  AppSpacing.xl,
                                  AppSpacing.xl,
                                ),
                                child: ReviewBloomCard(
                                  dueCount: stats.dueForReview,
                                  onStartReview: () =>
                                      context.push(AppRoutes.review),
                                ),
                              ),

                            Expanded(
                              child: RefreshIndicator(
                                color: primary,
                                onRefresh: viewModel.refresh,
                                child: VocabularyWordList(
                                  words: words,
                                  expanded: expanded,
                                  searchQuery: searchQuery,
                                  isDark: isDark,
                                  onToggleExpanded:
                                      viewModel.toggleCardExpanded,
                                  onDelete: onDelete,
                                  onCycleDifficulty: viewModel.cycleDifficulty,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
