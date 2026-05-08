import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/models/calendar_day_stats.dart';

class StreakCalendarSheetViewModel {
  final SessionRepository _sessionRepo;
  final PreferencesRepository _prefsRepo;

  final BehaviorSubject<DateTime> displayedMonth$ = BehaviorSubject.seeded(
    DateTime(DateTime.now().year, DateTime.now().month),
  );
  final BehaviorSubject<Map<String, CalendarDayStats>> calendarData$ =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<int> dailyGoalMinutes$ = BehaviorSubject.seeded(20);

  StreakCalendarSheetViewModel({
    SessionRepository? sessionRepo,
    PreferencesRepository? prefsRepo,
  }) : _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>();

  Future<void> init() async {
    final prefs = await _prefsRepo.get();
    dailyGoalMinutes$.add(prefs.dailyGoalMinutes);
    await _refreshCalendarData();
  }

  Future<void> changeMonth(int delta) async {
    final current = displayedMonth$.value;
    displayedMonth$.add(DateTime(current.year, current.month + delta));
    await _refreshCalendarData();
  }

  Future<void> _refreshCalendarData() async {
    final month = displayedMonth$.value;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final sessions = await _sessionRepo.getByDateRange(start, end);
    final dayAgg = <String, List<double>>{};

    for (final s in sessions) {
      final key = _dateKey(s.startedAt);
      dayAgg.putIfAbsent(key, () => []).add(s.durationMinutes);
    }

    final goal = dailyGoalMinutes$.value;
    final map = <String, CalendarDayStats>{};
    for (final entry in dayAgg.entries) {
      final totalMin = entry.value.fold<double>(0, (s, v) => s + v);
      map[entry.key] = CalendarDayStats(
        minutesRead: totalMin,
        sessionsCount: entry.value.length,
        targetMet: totalMin >= goal,
      );
    }

    calendarData$.add(map);
  }

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void dispose() {
    displayedMonth$.close();
    calendarData$.close();
    dailyGoalMinutes$.close();
  }
}
