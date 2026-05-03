import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:read_it/app.dart' show libraryChangeNotifier;
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/services/celebration_service.dart';
import 'package:read_it/core/services/share_card_service.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/data/models/celebration_data.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:read_it/presentation/home/widgets/continue_reading_card.dart';
import 'package:read_it/presentation/home/widgets/daily_insight_card.dart';
import 'package:read_it/presentation/home/widgets/home_empty_hero.dart';
import 'package:read_it/presentation/home/widgets/home_loading_skeleton.dart';
import 'package:read_it/presentation/home/widgets/document_shelf.dart';
import 'package:read_it/presentation/home/widgets/greeting_header.dart';
import 'package:read_it/presentation/home/widgets/import_content_sheet.dart';
import 'package:read_it/presentation/home/widgets/progress_row.dart';
import 'package:read_it/presentation/widgets/brand_mark.dart';
import 'package:read_it/presentation/home/widgets/streak_calendar_sheet.dart';
import 'package:read_it/presentation/home/widgets/streak_reset_banner.dart';
import 'package:read_it/presentation/widgets/celebration_overlay.dart';
import 'package:read_it/presentation/widgets/daily_target_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late final CelebrationService _celebrationService;
  late final AnimationController _staggerController;
  bool _celebrationChecked = false;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: AppDurations.stagger,
    );
    _viewModel = HomeViewModel();
    _celebrationService = getIt<CelebrationService>();
    _celebrationService.startListening();
    libraryChangeNotifier.addListener(_onLibraryChanged);
    _viewModel.init().then((_) {
      if (!mounted) return;
      _checkCelebrations();
    });
  }

  void _checkCelebrations() {
    if (_celebrationChecked) return;
    _celebrationChecked = true;
    _celebrationService.checkDailyTarget();
    final stats = _viewModel.stats$.value;
    _celebrationService.checkWordsMilestone(stats.totalWordsRead);

    final pending = _celebrationService.pendingCelebration$.value;
    if (pending != null) {
      _showCelebration(pending);
    }
  }

  void _showCelebration(CelebrationData celebration) {
    final shareKey = GlobalKey();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, _, _) => CelebrationOverlay(
          celebration: celebration,
          shareCardKey: shareKey,
          onContinue: () {
            _celebrationService.clearPending();
            Navigator.of(context).pop();
          },
          onShare: () async {
            final shareService = getIt<ShareCardService>();
            await shareService.captureAndShare(shareKey);
          },
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppDurations.calm,
        reverseTransitionDuration: AppDurations.normal,
      ),
    );
  }

  void _onLibraryChanged() => _viewModel.refresh();

  @override
  void dispose() {
    libraryChangeNotifier.removeListener(_onLibraryChanged);
    _staggerController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // ── Import ──────────────────────────────────────────────────────────────────

  void _showImportSheet() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.barrierOverlay,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) =>
            ImportContentSheet(onContentAdded: () => _viewModel.refresh()),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: AppDurations.smooth,
        reverseTransitionDuration: AppDurations.calm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.xl,
        title: const BrandMark(),
        centerTitle: false,
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, 0.4),
                  colors: [AppColors.homeGradientTop, AppColors.surface],
                ),
              )
            : null,
        child: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          builder: (context, loadingSnap) {
            final isLoading = loadingSnap.data ?? true;

            if (isLoading) {
              return HomeLoadingSkeleton(isDark: isDark);
            }

            if (!_hasAnimated) {
              _hasAnimated = true;
              _staggerController.forward();
            }

            return RefreshIndicator(
              color: isDark ? AppColors.primary : AppColors.lightPrimary,
              onRefresh: _viewModel.refresh,
              child: _HomeBody(
                viewModel: _viewModel,
                onImport: _showImportSheet,
                staggerController: _staggerController,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Staggered body ──────────────────────────────────────────────────────────

typedef _HomeData = ({
  List<DocumentModel> docs,
  HomeStats stats,
  DocumentModel? current,
  HomeFeatureMode currentMode,
  StreakModel streak,
  List<ReadingSessionModel> sessions,
  bool streakJustBroke,
});

class _HomeBody extends StatefulWidget {
  final HomeViewModel viewModel;
  final VoidCallback onImport;
  final AnimationController staggerController;

  const _HomeBody({
    required this.viewModel,
    required this.onImport,
    required this.staggerController,
  });

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  AnimationController get _staggerController => widget.staggerController;

  Widget _staggered(int index, Widget child) {
    final begin = (index * 0.12).clamp(0.0, 0.7);
    final end = (begin + 0.3).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _staggerController,
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
      await widget.viewModel.updateDailyGoal(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_HomeData>(
      stream: Rx.combineLatest7(
        widget.viewModel.documents$,
        widget.viewModel.stats$,
        widget.viewModel.currentDocument$,
        widget.viewModel.currentDocumentMode$,
        widget.viewModel.streak$,
        widget.viewModel.recentSessions$,
        widget.viewModel.streakJustBroke$,
        (docs, stats, current, mode, streak, sessions, streakJustBroke) => (
          docs: docs,
          stats: stats,
          current: current,
          currentMode: mode,
          streak: streak,
          sessions: sessions,
          streakJustBroke: streakJustBroke,
        ),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();

        final hasDocuments = data.docs.isNotEmpty && data.current != null;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),

                  // ── Greeting header ──
                  _staggered(
                    0,
                    GreetingHeader(
                      userName: data.stats.userName,
                    ),
                  ),

                  // ── Streak reset banner ──
                  if (data.streakJustBroke) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _staggered(
                      0,
                      StreakResetBanner(
                        onDismiss: () => widget.viewModel.clearStreakBroke(),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // ── Progress row — streak + daily goal (always visible) ──
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
                    // ── Empty state — no documents ──
                    _staggered(2, HomeEmptyHero(onImport: widget.onImport)),
                  ] else ...[
                    // ── Daily insight tip ──
                    _staggered(
                      2,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: const DailyInsightCard(),
                      ),
                    ),

                    // ── Continue reading card — primary CTA ──
                    const SizedBox(height: AppSpacing.xl),
                    _staggered(
                      3,
                      ContinueReadingCard(
                        document: data.current!,
                        avgWpm: data.stats.avgSpeedWpm,
                        savedWpm: data.stats.savedSpeedWpm,
                        mode: data.currentMode,
                        onContinueReading: () async {
                          final restart =
                              data.currentMode == HomeFeatureMode.readAgain;
                          final query = restart ? '?restart=true' : '';
                          await context.push(
                            '${AppRoutes.reading}/${data.current!.id}$query',
                          );
                          if (context.mounted) {
                            widget.viewModel.refresh();
                          }
                        },
                      ),
                    ),

                    // ── Document shelf ──
                    if (data.docs.length > 1) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _staggered(
                        4,
                        DocumentShelf(
                          documents: data.docs,
                          currentDocId: data.current?.id,
                          onReturn: () => widget.viewModel.refresh(),
                        ),
                      ),
                    ],

                  ],

                  const SizedBox(height: AppSpacing.bottomNavClearance + AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
