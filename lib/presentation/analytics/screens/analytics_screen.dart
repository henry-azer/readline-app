import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/widgets/brand_mark.dart';
import 'package:read_it/data/models/milestone_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/presentation/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:read_it/presentation/analytics/widgets/activity_feed.dart';
import 'package:read_it/presentation/analytics/widgets/daily_progress_section.dart';
import 'package:read_it/presentation/analytics/widgets/growth_insight_card.dart';
import 'package:read_it/presentation/analytics/widgets/reading_volume_chart.dart';
import 'package:read_it/presentation/analytics/widgets/stats_grid.dart';
import 'package:read_it/presentation/analytics/widgets/streak_calendar.dart';
import 'package:read_it/presentation/analytics/widgets/streak_card.dart';
import 'package:read_it/presentation/analytics/widgets/velocity_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnalyticsViewModel();
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
        titleSpacing: AppSpacing.lg,
        title: const BrandMark(),
        centerTitle: false,
        actions: [
          StreamBuilder<bool>(
            stream: _viewModel.isLoading$,
            builder: (context, snap) {
              final loading = snap.data == true;
              return IconButton(
                icon: loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: onSurfaceVariant,
                        ),
                      )
                    : Icon(Icons.refresh_rounded, color: onSurfaceVariant),
                onPressed: loading ? null : _viewModel.refresh,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: _viewModel.refresh,
        child: _AnalyticsBody(viewModel: _viewModel),
      ),
    );
  }
}

// ── Body ───��──────────────��──────────────────────────────────────────────────

class _AnalyticsBody extends StatelessWidget {
  final AnalyticsViewModel viewModel;

  const _AnalyticsBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return StreamBuilder<StreakModel>(
      stream: viewModel.streak$,
      builder: (context, streakSnap) {
        return StreamBuilder<AnalyticsTotalStats>(
          stream: viewModel.totalStats$,
          builder: (context, statsSnap) {
            return StreamBuilder<List<ReadingSessionModel>>(
              stream: viewModel.recentSessions$,
              builder: (context, sessionsSnap) {
                final streak = streakSnap.data ?? const StreakModel();
                final stats = statsSnap.data ?? const AnalyticsTotalStats();
                final sessions = sessionsSnap.data ?? const [];

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Headline
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xs,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.analyticsYourProgress.tr,
                              style: AppTypography.label.copyWith(
                                color: onSurfaceVariant,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.micro),
                            Text(
                              AppStrings.analyticsReadingInsights.tr,
                              style: AppTypography.headlineLarge.copyWith(
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Streak card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: StreakCard(streak: streak),
                      ),
                    ),

                    // Daily progress section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: _SectionHeader(
                          title: AppStrings.analyticsSectionDailyProgress.tr,
                          subtitle: AppStrings
                              .analyticsSectionDailyProgressSubtitle
                              .tr,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: StreamBuilder<double>(
                          stream: viewModel.todayMinutes$,
                          builder: (context, todaySnap) {
                            return StreamBuilder<int>(
                              stream: viewModel.dailyGoalMinutes$,
                              builder: (context, goalSnap) {
                                return StreamBuilder<List<WeekDayProgress>>(
                                  stream: viewModel.weekProgress$,
                                  builder: (context, weekSnap) {
                                    return DailyProgressSection(
                                      todayMinutes: todaySnap.data ?? 0,
                                      dailyGoalMinutes: goalSnap.data ?? 20,
                                      weekProgress: weekSnap.data ?? const [],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Stats grid
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: StatsGrid(
                          stats: stats,
                        ),
                      ),
                    ),

                    // Growth insight
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: GrowthInsightCard(
                          recentSessions: sessions,
                          streak: streak,
                        ),
                      ),
                    ),

                    // Streak Calendar section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: _SectionHeader(
                          title: AppStrings.analyticsSectionCalendar.tr,
                          subtitle:
                              AppStrings.analyticsSectionCalendarSubtitle.tr,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: StreamBuilder<DateTime>(
                          stream: viewModel.calendarMonth$,
                          builder: (context, monthSnap) {
                            return StreamBuilder<Map<String, CalendarDayStats>>(
                              stream: viewModel.calendarData$,
                              builder: (context, calSnap) {
                                return StreamBuilder<int>(
                                  stream: viewModel.dailyGoalMinutes$,
                                  builder: (context, goalSnap) {
                                    return StreakCalendar(
                                      displayedMonth:
                                          monthSnap.data ??
                                          DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                          ),
                                      calendarData: calSnap.data ?? const {},
                                      dailyGoalMinutes: goalSnap.data ?? 20,
                                      onChangeMonth: viewModel.changeMonth,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Reading Volume section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: _SectionHeader(
                          title: AppStrings.analyticsSectionVolume.tr,
                          subtitle:
                              AppStrings.analyticsSectionVolumeSubtitle.tr,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: StreamBuilder<VolumeChartData>(
                          stream: viewModel.volumeData$,
                          builder: (context, volSnap) {
                            return StreamBuilder<VolumePeriod>(
                              stream: viewModel.selectedPeriod$,
                              builder: (context, periodSnap) {
                                return ReadingVolumeChart(
                                  data: volSnap.data ?? const VolumeChartData(),
                                  selectedPeriod:
                                      periodSnap.data ?? VolumePeriod.days7,
                                  onPeriodChanged: viewModel.changePeriod,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Reading Velocity section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: _SectionHeader(
                          title: AppStrings.analyticsSectionVelocity.tr,
                          subtitle:
                              AppStrings.analyticsSectionVelocitySubtitle.tr,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        child: StreamBuilder<VelocityChartData>(
                          stream: viewModel.velocityData$,
                          builder: (context, velSnap) {
                            return VelocityChart(
                              data: velSnap.data ?? const VelocityChartData(),
                            );
                          },
                        ),
                      ),
                    ),

                    // Activity Feed section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: _SectionHeader(
                          title: AppStrings.analyticsSectionActivityFeed.tr,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.bottomNavClearance,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: StreamBuilder<bool>(
                          stream: viewModel.hasMoreSessions$,
                          builder: (context, hasMoreSnap) {
                            return StreamBuilder<List<MilestoneModel>>(
                              stream: viewModel.milestones$,
                              builder: (context, milestoneSnap) {
                                return ActivityFeed(
                                  sessions: sessions,
                                  milestones: milestoneSnap.data ?? const [],
                                  hasMore: hasMoreSnap.data ?? false,
                                  onLoadMore: viewModel.loadMoreSessions,
                                );
                              },
                            );
                          },
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
  }
}

// ── Section header ───────���────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.sectionHeader.copyWith(color: onSurface),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.micro),
          Text(
            subtitle!,
            style: AppTypography.bodySmall.copyWith(color: onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
