import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/vocabulary_word_model.dart';
import 'package:read_it/presentation/vocabulary/viewmodels/vocabulary_viewmodel.dart';
import 'package:read_it/presentation/vocabulary/widgets/daily_insight_card.dart';
import 'package:read_it/presentation/vocabulary/widgets/review_bloom_card.dart';
import 'package:read_it/presentation/vocabulary/widgets/word_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: onSurface),
          onPressed: () {},
        ),
        title: Text(
          AppStrings.vocabTitle.tr,
          style: AppTypography.titleLarge.copyWith(color: onSurface),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: onSurfaceVariant),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        foregroundColor: isDark
            ? AppColors.onPrimary
            : AppColors.lightOnPrimary,
        onPressed: () => _showAddWordDialog(context),
        child: const Icon(Icons.add_rounded),
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
            child: _VocabularyBody(viewModel: _viewModel),
          );
        },
      ),
    );
  }

  void _showAddWordDialog(BuildContext context) {
    final isDark = context.isDark;
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final surfaceBg = isDark
            ? AppColors.surfaceContainerHigh
            : AppColors.lightSurface;
        final onSurf = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
        final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

        return AlertDialog(
          backgroundColor: surfaceBg,
          title: Text(
            AppStrings.vocabAddWordTitle.tr,
            style: AppTypography.headlineMedium.copyWith(color: onSurf),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTypography.bodyLarge.copyWith(color: onSurf),
            decoration: InputDecoration(
              hintText: AppStrings.vocabAddWordHint.tr,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(ctx).pop();
              },
              child: Text(
                AppStrings.cancel.tr,
                style: AppTypography.button.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Stub — manual add not fully implemented yet
                controller.dispose();
                Navigator.of(ctx).pop();
              },
              child: Text(
                AppStrings.add.tr,
                style: AppTypography.button.copyWith(
                  color: primary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _VocabularyBody extends StatelessWidget {
  final VocabularyViewModel viewModel;

  const _VocabularyBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
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
                final words = wordsSnap.data ?? const [];
                final filter = filterSnap.data ?? 'all';
                final stats = statsSnap.data ?? const VocabularyStats();

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xs,
                          AppSpacing.xl,
                          AppSpacing.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.vocabPersonalWordBank.tr,
                              style: AppTypography.label.copyWith(
                                color: onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: AppTypography.displayMedium.copyWith(
                                  color: onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${AppStrings.vocabMasterThe.tr}\n',
                                  ),
                                  TextSpan(
                                    text: AppStrings.vocabUnspoken.tr,
                                    style: AppTypography.displayMedium.copyWith(
                                      color: isDark
                                          ? AppColors.primary
                                          : AppColors.lightPrimary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              AppStrings.vocabCollected.trParams({
                                'n': '${stats.total}',
                              }),
                              style: AppTypography.label.copyWith(
                                color: onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter chips
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: _FilterChips(
                          activeFilter: filter,
                          onFilterChanged: viewModel.setFilter,
                          stats: stats,
                        ),
                      ),
                    ),

                    // Review bloom card (when words are due)
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
                            onStartReview: () => context.go(AppRoutes.review),
                          ),
                        ),
                      ),

                    // Daily insight card
                    SliverToBoxAdapter(
                      child: StreamBuilder<List<VocabularyWordModel>>(
                        stream: viewModel.allWords$,
                        builder: (context, allSnap) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              0,
                              AppSpacing.xl,
                              AppSpacing.md,
                            ),
                            child: DailyInsightCard(
                              words: allSnap.data ?? const [],
                            ),
                          );
                        },
                      ),
                    ),

                    // Words list or empty state
                    if (words.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(filter: filter, isDark: isDark),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xxxxl + AppSpacing.xxl,
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
                                onBookmarkToggle: () =>
                                    viewModel.toggleBookmark(word.id),
                                onDelete: () => viewModel.deleteWord(word.id),
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  final bool isDark;

  const _EmptyState({required this.filter, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final (headline, body) = switch (filter) {
      'new' ||
      'fresh' => (AppStrings.vocabEmptyNew.tr, AppStrings.vocabEmptyNewBody.tr),
      'learning' => (
        AppStrings.vocabEmptyLearning.tr,
        AppStrings.vocabEmptyLearningBody.tr,
      ),
      'mastered' => (
        AppStrings.vocabEmptyMastered.tr,
        AppStrings.vocabEmptyMasteredBody.tr,
      ),
      'bookmarked' => (
        AppStrings.vocabEmptyBookmarked.tr,
        AppStrings.vocabEmptyBookmarkedBody.tr,
      ),
      _ => (AppStrings.vocabEmptyAll.tr, AppStrings.vocabEmptyAllBody.tr),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              headline,
              style: AppTypography.headlineMedium.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
