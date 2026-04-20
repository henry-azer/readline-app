import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/presentation/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:read_it/presentation/analytics/widgets/growth_insight_card.dart';
import 'package:read_it/presentation/analytics/widgets/reading_volume_chart.dart';
import 'package:read_it/presentation/analytics/widgets/recent_activity_list.dart';
import 'package:read_it/presentation/analytics/widgets/stats_grid.dart';
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
          AppStrings.analyticsTitle.tr,
          style: AppTypography.titleLarge.copyWith(color: onSurface),
        ),
        centerTitle: false,
        actions: [
          // Refresh button
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
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () => context.push(AppRoutes.settings),
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

// ── Body ─────────────────────────────────────────────────────────────────────

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
            return StreamBuilder<WeeklyStats>(
              stream: viewModel.weeklyStats$,
              builder: (context, weeklySnap) {
                return StreamBuilder<MonthlyVelocity>(
                  stream: viewModel.monthlyVelocity$,
                  builder: (context, velocitySnap) {
                    return StreamBuilder<List<ReadingSessionModel>>(
                      stream: viewModel.recentSessions$,
                      builder: (context, sessionsSnap) {
                        final streak = streakSnap.data ?? const StreakModel();
                        final stats =
                            statsSnap.data ?? const AnalyticsTotalStats();
                        final weekly = weeklySnap.data ?? const WeeklyStats();
                        final velocity =
                            velocitySnap.data ?? const MonthlyVelocity();
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
                                    const SizedBox(height: 2),
                                    Text(
                                      AppStrings.analyticsReadingInsights.tr,
                                      style: AppTypography.headlineLarge
                                          .copyWith(color: onSurface),
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
                                  AppSpacing.md,
                                ),
                                child: StreakCard(streak: streak),
                              ),
                            ),

                            // Stats grid
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  0,
                                  AppSpacing.xl,
                                  AppSpacing.md,
                                ),
                                child: StatsGrid(
                                  stats: stats,
                                  currentStreak: streak.currentStreak,
                                  longestStreak: streak.longestStreak,
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
                                  subtitle: AppStrings
                                      .analyticsSectionVolumeSubtitle
                                      .tr,
                                  badge: AppStrings.analyticsBadgePast7Days.tr,
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
                                child: ReadingVolumeChart(stats: weekly),
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
                                  subtitle: AppStrings
                                      .analyticsSectionVelocitySubtitle
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
                                child: VelocityChart(velocity: velocity),
                              ),
                            ),

                            // Recent Activity section
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  0,
                                  AppSpacing.xl,
                                  AppSpacing.sm,
                                ),
                                child: _SectionHeader(
                                  title: AppStrings
                                      .analyticsSectionRecentActivity
                                      .tr,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                0,
                                AppSpacing.xl,
                                AppSpacing.xxxxl + AppSpacing.xxl,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: RecentActivityList(sessions: sessions),
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

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badge;

  const _SectionHeader({required this.title, this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final badgeBg = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineMedium.copyWith(
                  color: onSurface,
                  fontSize: 18,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Text(
              badge!,
              style: AppTypography.label.copyWith(
                color: onSurfaceVariant,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}
