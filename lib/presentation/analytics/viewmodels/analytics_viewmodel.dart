import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/services/streak_service.dart';
import 'package:read_it/data/contracts/session_repository.dart';
import 'package:read_it/data/contracts/vocabulary_repository.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';

class AnalyticsTotalStats {
  final double totalReadingTimeHours;
  final int totalWordsRead;
  final int avgWpm;
  final int totalSessions;
  final int vocabCount;
  final double avgFocusScore;

  const AnalyticsTotalStats({
    this.totalReadingTimeHours = 0,
    this.totalWordsRead = 0,
    this.avgWpm = 0,
    this.totalSessions = 0,
    this.vocabCount = 0,
    this.avgFocusScore = 0,
  });
}

/// Words read per day for the last 7 days (Mon → Sun order).
class WeeklyStats {
  /// Day labels: Mon, Tue, Wed, Thu, Fri, Sat, Sun
  final List<String> dayLabels;

  /// Words read per matching day (7 entries).
  final List<int> wordsPerDay;

  const WeeklyStats({
    this.dayLabels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.wordsPerDay = const [0, 0, 0, 0, 0, 0, 0],
  });
}

/// Average WPM per week for the last 4 weeks.
class MonthlyVelocity {
  final List<String> weekLabels;
  final List<double> avgWpmPerWeek;

  const MonthlyVelocity({
    this.weekLabels = const ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
    this.avgWpmPerWeek = const [0, 0, 0, 0],
  });
}

class AnalyticsViewModel {
  final SessionRepository _sessionRepo;
  final VocabularyRepository _vocabRepo;
  final StreakService _streakService;

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

  AnalyticsViewModel({
    SessionRepository? sessionRepo,
    VocabularyRepository? vocabRepo,
    StreakService? streakService,
  }) : _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>(),
       _streakService = streakService ?? getIt<StreakService>();

  Future<void> init() async => refresh();

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      await _streakService.refresh();
      streak$.add(_streakService.streak$.value);

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      // Use a very old start date to capture all sessions for total stats
      final allTimeStart = DateTime(2020, 1, 1);

      final results = await Future.wait([
        _sessionRepo.getRecent(10),
        _sessionRepo.getByDateRange(thirtyDaysAgo, now),
        _vocabRepo.getAll(),
        _sessionRepo.getByDateRange(allTimeStart, now),
      ]);

      final recent = results[0] as List<ReadingSessionModel>;
      final last30Days = results[1] as List<ReadingSessionModel>;
      final vocab = results[2];
      final allSessions = results[3] as List<ReadingSessionModel>;

      recentSessions$.add(recent);

      weeklyStats$.add(_computeWeeklyStats(last30Days, now));
      monthlyVelocity$.add(_computeMonthlyVelocity(last30Days, now));
      totalStats$.add(_computeTotalStats(allSessions, vocab.length));
    } finally {
      isLoading$.add(false);
    }
  }

  WeeklyStats _computeWeeklyStats(
    List<ReadingSessionModel> sessions,
    DateTime now,
  ) {
    // Find most-recent Monday
    final today = DateTime(now.year, now.month, now.day);
    final mondayOffset = today.weekday - 1; // weekday: 1=Mon, 7=Sun
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
  ) {
    if (sessions.isEmpty) {
      return AnalyticsTotalStats(vocabCount: vocabCount);
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

    return AnalyticsTotalStats(
      totalReadingTimeHours: totalMinutes / 60,
      totalWordsRead: totalWords,
      avgWpm: avgWpm,
      totalSessions: sessions.length,
      vocabCount: vocabCount,
      avgFocusScore: avgFocus,
    );
  }

  void dispose() {
    streak$.close();
    recentSessions$.close();
    weeklyStats$.close();
    monthlyVelocity$.close();
    totalStats$.close();
    isLoading$.close();
  }
}
