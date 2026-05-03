import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/services/streak_service.dart';
import 'package:read_it/data/datasources/local/hive_milestone_source.dart';
import 'package:read_it/data/models/milestone_model.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/contracts/session_repository.dart';
import 'package:read_it/data/contracts/vocabulary_repository.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';

// ── Data classes ──────────────────────────────────────────────────────────────

class AnalyticsTotalStats {
  final double totalReadingTimeHours;
  final int totalWordsRead;
  final int avgWpm;
  final int totalSessions;
  final int vocabCount;
  final double avgFocusScore;
  final double avgSessionMinutes;
  final int currentStreak;
  final int longestStreak;

  const AnalyticsTotalStats({
    this.totalReadingTimeHours = 0,
    this.totalWordsRead = 0,
    this.avgWpm = 0,
    this.totalSessions = 0,
    this.vocabCount = 0,
    this.avgFocusScore = 0,
    this.avgSessionMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });
}

class WeeklyStats {
  final List<String> dayLabels;
  final List<int> wordsPerDay;

  const WeeklyStats({
    this.dayLabels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.wordsPerDay = const [0, 0, 0, 0, 0, 0, 0],
  });
}

class MonthlyVelocity {
  final List<String> weekLabels;
  final List<double> avgWpmPerWeek;

  const MonthlyVelocity({
    this.weekLabels = const ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
    this.avgWpmPerWeek = const [0, 0, 0, 0],
  });
}

/// Stats for the volume chart with date-keyed data and daily target.
class VolumeChartData {
  final List<DayVolume> days;
  final int dailyTargetWords;
  final int averageWords;

  const VolumeChartData({
    this.days = const [],
    this.dailyTargetWords = 0,
    this.averageWords = 0,
  });
}

class DayVolume {
  final DateTime date;
  final int wordsRead;

  const DayVolume({required this.date, this.wordsRead = 0});
}

/// Stats for the velocity chart with daily WPM data.
class VelocityChartData {
  final List<DayVelocity> days;
  final List<double> movingAverage;
  final double trendPercent;

  const VelocityChartData({
    this.days = const [],
    this.movingAverage = const [],
    this.trendPercent = 0,
  });
}

class DayVelocity {
  final DateTime date;
  final double avgWpm;

  const DayVelocity({required this.date, this.avgWpm = 0});
}

/// Daily progress for the week-at-a-glance.
class WeekDayProgress {
  final DateTime date;
  final double minutesRead;
  final bool targetMet;

  const WeekDayProgress({
    required this.date,
    this.minutesRead = 0,
    this.targetMet = false,
  });
}

/// Day stats for the calendar heat map.
class CalendarDayStats {
  final double minutesRead;
  final int sessionsCount;
  final bool targetMet;

  const CalendarDayStats({
    this.minutesRead = 0,
    this.sessionsCount = 0,
    this.targetMet = false,
  });
}

/// Period enum for volume chart toggle.
enum VolumePeriod { days7, days30, days90, allTime }

// ── ViewModel ────────────────────────────────────────────────────────────────

class AnalyticsViewModel {
  final SessionRepository _sessionRepo;
  final VocabularyRepository _vocabRepo;
  final StreakService _streakService;
  final PreferencesRepository _prefsRepo;
  final HiveMilestoneSource _milestoneSource;

  // ── Streams ──
  final BehaviorSubject<StreakModel> streak$ = BehaviorSubject.seeded(
    const StreakModel(),
  );
  final BehaviorSubject<List<ReadingSessionModel>> recentSessions$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<WeeklyStats> weeklyStats$ = BehaviorSubject.seeded(
    const WeeklyStats(),
  );
  final BehaviorSubject<MonthlyVelocity> monthlyVelocity$ =
      BehaviorSubject.seeded(const MonthlyVelocity());
  final BehaviorSubject<AnalyticsTotalStats> totalStats$ =
      BehaviorSubject.seeded(const AnalyticsTotalStats());
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<WeekDayProgress>> weekProgress$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<Map<String, CalendarDayStats>> calendarData$ =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<DateTime> calendarMonth$ = BehaviorSubject.seeded(
    DateTime(DateTime.now().year, DateTime.now().month),
  );
  final BehaviorSubject<VolumeChartData> volumeData$ = BehaviorSubject.seeded(
    const VolumeChartData(),
  );
  final BehaviorSubject<VelocityChartData> velocityData$ =
      BehaviorSubject.seeded(const VelocityChartData());
  final BehaviorSubject<VolumePeriod> selectedPeriod$ = BehaviorSubject.seeded(
    VolumePeriod.days7,
  );
  final BehaviorSubject<double> todayMinutes$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<int> dailyGoalMinutes$ = BehaviorSubject.seeded(20);
  final BehaviorSubject<List<MilestoneModel>> milestones$ =
      BehaviorSubject.seeded(const []);

  // Pagination
  int _sessionOffset = 0;
  static const int _sessionPageSize = 50;
  final BehaviorSubject<bool> hasMoreSessions$ = BehaviorSubject.seeded(true);

  // Cached all-sessions for computation
  List<ReadingSessionModel> _allSessions = [];
  int _dailyGoal = 20;

  AnalyticsViewModel({
    SessionRepository? sessionRepo,
    VocabularyRepository? vocabRepo,
    StreakService? streakService,
    PreferencesRepository? prefsRepo,
    HiveMilestoneSource? milestoneSource,
  }) : _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>(),
       _streakService = streakService ?? getIt<StreakService>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _milestoneSource = milestoneSource ?? getIt<HiveMilestoneSource>();

  Future<void> init() async => refresh();

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      // Load preferences for daily goal
      final prefs = await _prefsRepo.get();
      _dailyGoal = prefs.dailyGoalMinutes;
      dailyGoalMinutes$.add(_dailyGoal);

      await _streakService.refresh();
      streak$.add(_streakService.streak$.value);

      final now = DateTime.now();
      final allTimeStart = DateTime(2020, 1, 1);

      final results = await Future.wait([
        _sessionRepo.getByDateRange(allTimeStart, now),
        _vocabRepo.getAll(),
      ]);

      _allSessions = results[0] as List<ReadingSessionModel>;
      final vocab = results[1];
      final streak = _streakService.streak$.value;

      // Total stats
      totalStats$.add(_computeTotalStats(_allSessions, vocab.length, streak));

      // Weekly stats (for backward compat)
      final last30Days = _allSessions.where((s) {
        return !s.startedAt.isBefore(now.subtract(const Duration(days: 30)));
      }).toList();
      weeklyStats$.add(_computeWeeklyStats(last30Days, now));
      monthlyVelocity$.add(_computeMonthlyVelocity(last30Days, now));

      // Week progress (7-day at-a-glance)
      weekProgress$.add(_computeWeekProgress(now));

      // Today's minutes
      todayMinutes$.add(_computeTodayMinutes(now));

      // Calendar data for current month
      _refreshCalendarData();

      // Volume chart data for selected period
      _refreshVolumeData();

      // Velocity chart data
      velocityData$.add(_computeVelocityChartData(now));

      // Load milestones
      try {
        milestones$.add(await _milestoneSource.getAll());
      } catch (_) {
        milestones$.add(const []);
      }

      // Paginated recent sessions
      _sessionOffset = 0;
      final recentSlice = _getSessionsPage(0);
      recentSessions$.add(recentSlice);
      hasMoreSessions$.add(recentSlice.length >= _sessionPageSize);
    } finally {
      isLoading$.add(false);
    }
  }

  // ── Public actions ──

  void changePeriod(VolumePeriod period) {
    selectedPeriod$.add(period);
    _refreshVolumeData();
  }

  void changeMonth(int delta) {
    final current = calendarMonth$.value;
    final next = DateTime(current.year, current.month + delta);
    calendarMonth$.add(next);
    _refreshCalendarData();
  }

  void loadMoreSessions() {
    _sessionOffset += _sessionPageSize;
    final more = _getSessionsPage(_sessionOffset);
    final current = recentSessions$.value;
    recentSessions$.add([...current, ...more]);
    hasMoreSessions$.add(more.length >= _sessionPageSize);
  }

  // ── Private computations ──

  List<ReadingSessionModel> _getSessionsPage(int offset) {
    // Sort descending by date
    final sorted = List<ReadingSessionModel>.from(_allSessions)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    if (offset >= sorted.length) return [];
    final end = (offset + _sessionPageSize).clamp(0, sorted.length);
    return sorted.sublist(offset, end);
  }

  double _computeTodayMinutes(DateTime now) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    double total = 0;
    for (final s in _allSessions) {
      final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      if (!d.isBefore(todayStart) && d.isBefore(todayEnd)) {
        total += s.durationMinutes;
      }
    }
    return total;
  }

  List<WeekDayProgress> _computeWeekProgress(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final mondayOffset = today.weekday - 1;
    final monday = today.subtract(Duration(days: mondayOffset));

    final result = <WeekDayProgress>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      double minutes = 0;
      for (final s in _allSessions) {
        final sd = DateTime(
          s.startedAt.year,
          s.startedAt.month,
          s.startedAt.day,
        );
        if (sd == day) {
          minutes += s.durationMinutes;
        }
      }
      result.add(
        WeekDayProgress(
          date: day,
          minutesRead: minutes,
          targetMet: minutes >= _dailyGoal,
        ),
      );
    }
    return result;
  }

  void _refreshCalendarData() {
    final month = calendarMonth$.value;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // Filter from cached _allSessions instead of re-querying Hive
    final sessions = _allSessions.where((s) {
      return !s.startedAt.isBefore(start) && !s.startedAt.isAfter(end);
    }).toList();

    final map = <String, CalendarDayStats>{};

    // Aggregate per day
    final dayAgg = <String, List<ReadingSessionModel>>{};
    for (final s in sessions) {
      final key = _dateKey(s.startedAt);
      dayAgg.putIfAbsent(key, () => []).add(s);
    }

    for (final entry in dayAgg.entries) {
      final totalMin = entry.value.fold<double>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );
      map[entry.key] = CalendarDayStats(
        minutesRead: totalMin,
        sessionsCount: entry.value.length,
        targetMet: totalMin >= _dailyGoal,
      );
    }

    calendarData$.add(map);
  }

  void _refreshVolumeData() {
    final period = selectedPeriod$.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int dayCount;
    switch (period) {
      case VolumePeriod.days7:
        dayCount = 7;
      case VolumePeriod.days30:
        dayCount = 30;
      case VolumePeriod.days90:
        dayCount = 90;
      case VolumePeriod.allTime:
        if (_allSessions.isEmpty) {
          dayCount = 30;
        } else {
          final earliest = _allSessions
              .map((s) => s.startedAt)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          dayCount =
              today
                  .difference(
                    DateTime(earliest.year, earliest.month, earliest.day),
                  )
                  .inDays +
              1;
          if (dayCount < 7) dayCount = 7;
        }
    }

    final startDate = today.subtract(Duration(days: dayCount - 1));
    final days = <DayVolume>[];
    int totalWords = 0;

    for (int i = 0; i < dayCount; i++) {
      final day = startDate.add(Duration(days: i));
      int words = 0;
      for (final s in _allSessions) {
        final sd = DateTime(
          s.startedAt.year,
          s.startedAt.month,
          s.startedAt.day,
        );
        if (sd == day) {
          words += s.wordsRead;
        }
      }
      days.add(DayVolume(date: day, wordsRead: words));
      totalWords += words;
    }

    // Estimate daily target in words: dailyGoal * avgWpm
    final avgWpm = totalStats$.value.avgWpm;
    final dailyTargetWords = _dailyGoal * (avgWpm > 0 ? avgWpm : 200);

    volumeData$.add(
      VolumeChartData(
        days: days,
        dailyTargetWords: dailyTargetWords,
        averageWords: dayCount > 0 ? totalWords ~/ dayCount : 0,
      ),
    );
  }

  VelocityChartData _computeVelocityChartData(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 27));

    final days = <DayVelocity>[];
    for (int i = 0; i < 28; i++) {
      final day = startDate.add(Duration(days: i));
      double totalWpm = 0;
      int count = 0;
      for (final s in _allSessions) {
        final sd = DateTime(
          s.startedAt.year,
          s.startedAt.month,
          s.startedAt.day,
        );
        if (sd == day && s.averageWpm > 0) {
          totalWpm += s.averageWpm;
          count++;
        }
      }
      days.add(
        DayVelocity(date: day, avgWpm: count > 0 ? totalWpm / count : 0),
      );
    }

    // 7-day rolling average
    final movingAvg = <double>[];
    for (int i = 0; i < days.length; i++) {
      final windowStart = (i - 6).clamp(0, days.length);
      final window = days.sublist(windowStart, i + 1);
      final nonZero = window.where((d) => d.avgWpm > 0).toList();
      if (nonZero.isEmpty) {
        movingAvg.add(0);
      } else {
        movingAvg.add(
          nonZero.fold<double>(0, (s, d) => s + d.avgWpm) / nonZero.length,
        );
      }
    }

    // Trend: compare first week avg vs last week avg
    double trendPct = 0;
    final firstWeekNonZero = movingAvg.take(7).where((v) => v > 0);
    final lastWeekNonZero = movingAvg.skip(21).where((v) => v > 0);
    if (firstWeekNonZero.isNotEmpty && lastWeekNonZero.isNotEmpty) {
      final firstAvg =
          firstWeekNonZero.reduce((a, b) => a + b) / firstWeekNonZero.length;
      final lastAvg =
          lastWeekNonZero.reduce((a, b) => a + b) / lastWeekNonZero.length;
      if (firstAvg > 0) {
        trendPct = ((lastAvg - firstAvg) / firstAvg) * 100;
      }
    }

    return VelocityChartData(
      days: days,
      movingAverage: movingAvg,
      trendPercent: trendPct,
    );
  }

  WeeklyStats _computeWeeklyStats(
    List<ReadingSessionModel> sessions,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final mondayOffset = today.weekday - 1;
    final monday = today.subtract(Duration(days: mondayOffset));

    final labels = [
      AppStrings.dayMon.tr,
      AppStrings.dayTue.tr,
      AppStrings.dayWed.tr,
      AppStrings.dayThu.tr,
      AppStrings.dayFri.tr,
      AppStrings.daySat.tr,
      AppStrings.daySun.tr,
    ];
    final wordsPerDay = List<int>.filled(7, 0);

    for (final s in sessions) {
      final sessionDay = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      final diff = sessionDay.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        wordsPerDay[diff] += s.wordsRead;
      }
    }

    return WeeklyStats(
      dayLabels: List.unmodifiable(labels),
      wordsPerDay: wordsPerDay,
    );
  }

  MonthlyVelocity _computeMonthlyVelocity(
    List<ReadingSessionModel> sessions,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    final weekLabels = <String>[];
    final avgWpmPerWeek = <double>[];

    for (int w = 3; w >= 0; w--) {
      final weekEnd = today.subtract(Duration(days: w * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      final weekSessions = sessions.where((s) {
        final d = DateTime(
          s.startedAt.year,
          s.startedAt.month,
          s.startedAt.day,
        );
        return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
      }).toList();

      final label = AppStrings.analyticsWeekLabel.trParams({'n': '${4 - w}'});
      weekLabels.add(label);

      if (weekSessions.isEmpty) {
        avgWpmPerWeek.add(0);
      } else {
        final total = weekSessions.fold<int>(0, (sum, s) => sum + s.averageWpm);
        avgWpmPerWeek.add(total / weekSessions.length);
      }
    }

    return MonthlyVelocity(
      weekLabels: weekLabels,
      avgWpmPerWeek: avgWpmPerWeek,
    );
  }

  AnalyticsTotalStats _computeTotalStats(
    List<ReadingSessionModel> sessions,
    int vocabCount,
    StreakModel streak,
  ) {
    if (sessions.isEmpty) {
      return AnalyticsTotalStats(
        vocabCount: vocabCount,
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
      );
    }

    final totalMinutes = sessions.fold<double>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    final totalWords = sessions.fold<int>(0, (sum, s) => sum + s.wordsRead);
    final avgWpm =
        sessions.fold<int>(0, (sum, s) => sum + s.averageWpm) ~/
        sessions.length;
    final avgFocus =
        sessions.fold<double>(0, (sum, s) => sum + s.focusScore) /
        sessions.length;
    final avgMinutes = totalMinutes / sessions.length;

    return AnalyticsTotalStats(
      totalReadingTimeHours: totalMinutes / 60,
      totalWordsRead: totalWords,
      avgWpm: avgWpm,
      totalSessions: sessions.length,
      vocabCount: vocabCount,
      avgFocusScore: avgFocus,
      avgSessionMinutes: avgMinutes,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
    );
  }

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void dispose() {
    streak$.close();
    recentSessions$.close();
    weeklyStats$.close();
    monthlyVelocity$.close();
    totalStats$.close();
    isLoading$.close();
    weekProgress$.close();
    calendarData$.close();
    calendarMonth$.close();
    volumeData$.close();
    velocityData$.close();
    selectedPeriod$.close();
    todayMinutes$.close();
    dailyGoalMinutes$.close();
    hasMoreSessions$.close();
    milestones$.close();
  }
}
