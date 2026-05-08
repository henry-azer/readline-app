import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/calendar_day_stats.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/features/analytics/widgets/streak_calendar.dart';
import 'package:readline_app/features/home/viewmodels/streak_calendar_sheet_viewmodel.dart';
import 'package:readline_app/features/home/widgets/stat_chip.dart';
import 'package:readline_app/widgets/sheet_handle.dart';

class StreakCalendarSheet extends StatefulWidget {
  final StreakModel streak;

  const StreakCalendarSheet({super.key, required this.streak});

  static Future<void> show(BuildContext context, StreakModel streak) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => StreakCalendarSheet(streak: streak),
    );
  }

  @override
  State<StreakCalendarSheet> createState() => _StreakCalendarSheetState();
}

class _StreakCalendarSheetState extends State<StreakCalendarSheet> {
  late final StreakCalendarSheetViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StreakCalendarSheetViewModel();
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
    final bgColor = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final streakColor = primary;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xlg),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xlg),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      const SheetHandle(),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              color: streakColor,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              AppStrings.homeStreakCalendarTitle.tr,
                              style: AppTypography.homeCalendarHeading.copyWith(
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Row(
                          children: [
                            StatChip(
                              value: '${widget.streak.currentStreak}',
                              label: AppStrings
                                  .homeStreakCalendarCurrentStreak.tr,
                              color: streakColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            StatChip(
                              value: '${widget.streak.longestStreak}',
                              label: AppStrings
                                  .homeStreakCalendarLongestStreak.tr,
                              color: primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            StatChip(
                              value: '${widget.streak.totalReadingDays}',
                              label:
                                  AppStrings.homeStreakCalendarTotalDays.tr,
                              color: isDark
                                  ? AppColors.success
                                  : AppColors.lightSuccess,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            0,
                            AppSpacing.xl,
                            AppSpacing.xxxl + bottomPadding,
                          ),
                          child: StreamBuilder<DateTime>(
                            stream: _viewModel.displayedMonth$,
                            builder: (context, monthSnap) {
                              return StreamBuilder<
                                  Map<String, CalendarDayStats>>(
                                stream: _viewModel.calendarData$,
                                builder: (context, calSnap) {
                                  return StreamBuilder<int>(
                                    stream: _viewModel.dailyGoalMinutes$,
                                    builder: (context, goalSnap) {
                                      return StreakCalendar(
                                        displayedMonth: monthSnap.data ??
                                            DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                            ),
                                        calendarData:
                                            calSnap.data ?? const {},
                                        dailyGoalMinutes: goalSnap.data ?? 20,
                                        onChangeMonth: _viewModel.changeMonth,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
