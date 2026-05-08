import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/calendar_day_stats.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/features/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:readline_app/features/analytics/widgets/daily_progress_section.dart';
import 'package:readline_app/features/analytics/widgets/growth_insight_card.dart';
import 'package:readline_app/features/analytics/widgets/reading_volume_chart.dart';
import 'package:readline_app/features/analytics/widgets/section_header.dart';
import 'package:readline_app/features/analytics/widgets/stats_grid.dart';
import 'package:readline_app/features/analytics/widgets/streak_calendar.dart';
import 'package:readline_app/features/analytics/widgets/streak_card.dart';
import 'package:readline_app/features/analytics/widgets/velocity_chart.dart';

class AnalyticsBody extends StatelessWidget {
  final AnalyticsViewModel viewModel;

  const AnalyticsBody({super.key, required this.viewModel});

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

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  children: [
                    Text(
                      AppStrings.analyticsYourProgress.tr,
                      style: AppTypography.analyticsEyebrow.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.micro),
                    Text(
                      AppStrings.analyticsReadingInsights.tr,
                      style: AppTypography.headlineLarge.copyWith(
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    StreakCard(streak: streak),

                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(
                      title: AppStrings.analyticsSectionDailyProgress.tr,
                      subtitle:
                          AppStrings.analyticsSectionDailyProgressSubtitle.tr,
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    StreamBuilder<double>(
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

                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(title: AppStrings.growthInsightLabel.tr),
                    const SizedBox(height: AppSpacing.smd),
                    GrowthInsightCard(
                      recentSessions: sessions,
                      streak: streak,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(
                      title: AppStrings.analyticsSectionOverview.tr,
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    StatsGrid(stats: stats),

                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(
                      title: AppStrings.analyticsSectionCalendar.tr,
                      subtitle:
                          AppStrings.analyticsSectionCalendarSubtitle.tr,
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    StreamBuilder<DateTime>(
                      stream: viewModel.calendarMonth$,
                      builder: (context, monthSnap) {
                        return StreamBuilder<Map<String, CalendarDayStats>>(
                          stream: viewModel.calendarData$,
                          builder: (context, calSnap) {
                            return StreamBuilder<int>(
                              stream: viewModel.dailyGoalMinutes$,
                              builder: (context, goalSnap) {
                                return StreakCalendar(
                                  displayedMonth: monthSnap.data ??
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

                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(
                      title: AppStrings.analyticsSectionVolume.tr,
                      subtitle: AppStrings.analyticsSectionVolumeSubtitle.tr,
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    StreamBuilder<VolumeChartData>(
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

                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(
                      title: AppStrings.analyticsSectionVelocity.tr,
                      subtitle:
                          AppStrings.analyticsSectionVelocitySubtitle.tr,
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    StreamBuilder<VelocityChartData>(
                      stream: viewModel.velocityData$,
                      builder: (context, velSnap) {
                        return VelocityChart(
                          data: velSnap.data ?? const VelocityChartData(),
                        );
                      },
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
