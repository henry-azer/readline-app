import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:readline_app/features/home/widgets/continue_reading_card.dart';
import 'package:readline_app/features/home/widgets/daily_insight_card.dart';
import 'package:readline_app/features/home/widgets/document_shelf.dart';
import 'package:readline_app/features/home/widgets/greeting_header.dart';
import 'package:readline_app/features/home/widgets/home_empty_hero.dart';
import 'package:readline_app/features/home/widgets/progress_row.dart';
import 'package:readline_app/features/home/widgets/streak_calendar_sheet.dart';
import 'package:readline_app/features/home/widgets/streak_reset_banner.dart';
import 'package:readline_app/widgets/daily_target_picker.dart';

typedef _HomeData = ({
  List<DocumentModel> docs,
  HomeStats stats,
  FeaturedDocument? featured,
  StreakModel streak,
  List<ReadingSessionModel> sessions,
  bool streakJustBroke,
  Map<String, double> actualMinutesByDoc,
});

class HomeBody extends StatelessWidget {
  final HomeViewModel viewModel;
  final VoidCallback onImport;
  final AnimationController staggerController;

  const HomeBody({
    super.key,
    required this.viewModel,
    required this.onImport,
    required this.staggerController,
  });

  Widget _staggered(int index, Widget child) {
    final begin = (index * 0.12).clamp(0.0, 0.7);
    final end = (begin + 0.3).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: staggerController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  Future<void> _showDailyTargetPicker(
    BuildContext context,
    int currentMinutes,
  ) async {
    final selected = await DailyTargetPicker.show(
      context,
      currentMinutes: currentMinutes,
    );
    if (selected != null && selected != currentMinutes) {
      await viewModel.updateDailyGoal(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_HomeData>(
      stream: Rx.combineLatest7(
        viewModel.documents$,
        viewModel.stats$,
        viewModel.featured$,
        viewModel.streak$,
        viewModel.recentSessions$,
        viewModel.streakJustBroke$,
        viewModel.actualMinutesByDoc$,
        (
          List<DocumentModel> docs,
          HomeStats stats,
          FeaturedDocument? featured,
          StreakModel streak,
          List<ReadingSessionModel> sessions,
          bool streakJustBroke,
          Map<String, double> actualMinutesByDoc,
        ) => (
          docs: docs,
          stats: stats,
          featured: featured,
          streak: streak,
          sessions: sessions,
          streakJustBroke: streakJustBroke,
          actualMinutesByDoc: actualMinutesByDoc,
        ),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();

        final hasDocuments = data.docs.isNotEmpty && data.featured != null;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),

                  _staggered(
                    0,
                    GreetingHeader(userName: data.stats.userName),
                  ),

                  if (data.streakJustBroke) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _staggered(
                      0,
                      StreakResetBanner(
                        onDismiss: () => viewModel.clearStreakBroke(),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  _staggered(
                    1,
                    ProgressRow(
                      streak: data.streak,
                      todayMinutes: data.stats.todayMinutes,
                      targetMinutes: data.stats.dailyGoalMinutes,
                      onStreakTap: () =>
                          StreakCalendarSheet.show(context, data.streak),
                      onGoalEditTap: () => _showDailyTargetPicker(
                        context,
                        data.stats.dailyGoalMinutes,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  if (!hasDocuments) ...[
                    _staggered(2, HomeEmptyHero(onImport: onImport)),
                  ] else ...[
                    _staggered(
                      2,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: const DailyInsightCard(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _staggered(
                      3,
                      ContinueReadingCard(
                        featured: data.featured!,
                        onContinueReading: () async {
                          final restart = data.featured!.mode ==
                              HomeFeatureMode.readAgain;
                          final query = restart ? '?restart=true' : '';
                          await context.push(
                            '${AppRoutes.reading}/${data.featured!.document.id}$query',
                          );
                          if (context.mounted) viewModel.refresh();
                        },
                      ),
                    ),

                    if (data.docs.length > 1) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _staggered(
                        4,
                        DocumentShelf(
                          documents: data.docs,
                          currentDocId: data.featured?.document.id,
                          onReturn: () => viewModel.refresh(),
                          avgWpm: data.stats.avgSpeedWpm,
                          savedWpm: data.stats.savedSpeedWpm,
                          actualMinutesByDoc: data.actualMinutesByDoc,
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(
                    height: AppSpacing.bottomNavClearance + AppSpacing.xxxl,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
