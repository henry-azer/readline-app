import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/viewmodels/vocabulary_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/review_bloom_card.dart';
import 'package:readline_app/features/library/widgets/library_search_bar.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_filter_sheet.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_sort_menu.dart';
import 'package:readline_app/features/vocabulary/widgets/no_search_results.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_empty_state.dart';
import 'package:readline_app/features/vocabulary/widgets/word_card.dart';
import 'package:readline_app/widgets/brand_mark.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late final VocabularyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VocabularyViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StreamBuilder<VocabFilterConfig>(
        stream: _viewModel.filterConfig$,
        builder: (context, snap) {
          final config = snap.data ?? const VocabFilterConfig();
          return VocabularyFilterSheet(
            initialConfig: config,
            sourceDocuments: _viewModel.sourceDocuments,
            onApply: _viewModel.setFilterConfig,
            onClearAll: _viewModel.clearFilters,
          );
        },
      ),
    );
  }

  Future<void> _handleDelete(VocabularyWordModel word) async {
    final deleted = await _viewModel.softDeleteWord(word.id);
    if (deleted == null || !mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.wordCardDeleted.trParams({'word': word.word}),
          style: AppTypography.bodyMedium,
        ),
        duration: AppDurations.snackbarLong,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.undo.tr,
          onPressed: () => _viewModel.restoreWord(deleted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: StreamBuilder<VocabularyStats>(
          stream: _viewModel.stats$,
          builder: (context, statsSnap) {
            final total = statsSnap.data?.total ?? 0;
            return AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: AppSpacing.xl,
              title: const BrandMark(),
              centerTitle: false,
              actions: [
                if (total > 0) ...[
                  // Filter button with active count badge
                  StreamBuilder<VocabFilterConfig>(
                    stream: _viewModel.filterConfig$,
                    builder: (context, snap) {
                      final config = snap.data ?? const VocabFilterConfig();
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: onSurfaceVariant,
                            ),
                            onPressed: _showFilterSheet,
                          ),
                          if (config.activeCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${config.activeCount}',
                                    style: AppTypography.label.copyWith(
                                      color: isDark
                                          ? AppColors.onPrimary
                                          : AppColors.lightOnPrimary,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  // Sort menu
                  StreamBuilder<VocabSortOption>(
                    stream: _viewModel.sortOption$,
                    builder: (context, sortSnap) {
                      return StreamBuilder<bool>(
                        stream: _viewModel.sortAscending$,
                        builder: (context, ascSnap) {
                          return VocabularySortMenu(
                            currentSort: sortSnap.data ?? VocabSortOption.dateAdded,
                            ascending: ascSnap.data ?? false,
                            onSortChanged: _viewModel.setSortOption,
                            onDirectionToggle: _viewModel.toggleSortDirection,
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<bool>(
        stream: _viewModel.isLoading$,
        builder: (context, loadingSnap) {
          if (loadingSnap.data == true) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          return RefreshIndicator(
            color: primary,
            onRefresh: _viewModel.refresh,
            child: _VocabularyBody(
              viewModel: _viewModel,
              onDelete: _handleDelete,
            ),
          );
        },
      ),
    );
  }

}

// ── Body ─────────────────────────────────────────────────────────────────────

class _VocabularyBody extends StatelessWidget {
  final VocabularyViewModel viewModel;
  final ValueChanged<VocabularyWordModel> onDelete;

  const _VocabularyBody({required this.viewModel, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

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

                        return CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // Header
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  AppSpacing.md,
                                  AppSpacing.xl,
                                  AppSpacing.xs,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.vocabTitle.tr,
                                      style: AppTypography.displayMedium.copyWith(
                                        color: isDark
                                            ? AppColors.onSurface
                                            : AppColors.lightOnSurface,
                                      ),
                                    ),
                                    if (stats.total > 0) ...[
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        AppStrings.vocabWordCount.trParams({
                                          'n': '${stats.total}',
                                        }),
                                        style: AppTypography.label.copyWith(
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // Search bar
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                  bottom: AppSpacing.xs,
                                ),
                                child: LibrarySearchBar(
                                  onChanged: viewModel.setSearchQuery,
                                  onClear: () =>
                                      viewModel.setSearchQuery(''),
                                  hintText: AppStrings.vocabSearchHint.tr,
                                ),
                              ),
                            ),

                            // Filter chips
                            if (stats.total > 0)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs,
                                  ),
                                  child: _FilterChips(
                                    activeFilter: filter,
                                    onFilterChanged: viewModel.setFilter,
                                    stats: stats,
                                  ),
                                ),
                              ),

                            // Review bloom card
                            if (stats.dueForReview > 0)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.xl,
                                    0,
                                    AppSpacing.xl,
                                    AppSpacing.md,
                                  ),
                                  child: ReviewBloomCard(
                                    dueCount: stats.dueForReview,
                                    onStartReview: () =>
                                        context.push(AppRoutes.review),
                                  ),
                                ),
                              ),

                            // Words list, no results, or empty state
                            if (words.isEmpty && searchQuery.isNotEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: VocabNoSearchResults(isDark: isDark),
                              )
                            else if (words.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: VocabularyEmptyState(
                                  filter: filter,
                                  isDark: isDark,
                                ),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  0,
                                  AppSpacing.xl,
                                  AppSpacing.bottomNavClearance,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final word = words[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: WordCard(
                                        word: word,
                                        isExpanded: expanded.contains(word.id),
                                        onTap: () => viewModel
                                            .toggleCardExpanded(word.id),
                                        onBookmarkToggle: () =>
                                            viewModel.toggleBookmark(word.id),
                                        onDelete: () => onDelete(word),
                                        onDifficultyTap: () =>
                                            viewModel.cycleDifficulty(word.id),
                                      ),
                                    );
                                  }, childCount: words.length),
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

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final String activeFilter;
  final void Function(String) onFilterChanged;
  final VocabularyStats stats;

  const _FilterChips({
    required this.activeFilter,
    required this.onFilterChanged,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final filters = [
      ('all', AppStrings.vocabFilterAll.tr, stats.total),
      ('new', AppStrings.vocabFilterNew.tr, stats.fresh),
      ('learning', AppStrings.vocabFilterLearning.tr, stats.learning),
      ('mastered', AppStrings.vocabFilterMastered.tr, stats.mastered),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: filters.map((f) {
          final (key, label, count) = f;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: _Chip(
              label: label,
              count: count,
              isSelected: activeFilter == key,
              onTap: () => onFilterChanged(key),
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _Chip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.msl,
          vertical: AppSpacing.sxs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : surfaceHigh,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? (isDark ? AppColors.onPrimary : AppColors.lightOnPrimary)
                : onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
