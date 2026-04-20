import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/data/datasources/local/hive_streak_source.dart';
import 'package:read_it/data/models/streak_model.dart';

class StreakService {
  final HiveStreakSource _source;

  final BehaviorSubject<StreakModel> streak$ = BehaviorSubject.seeded(
    const StreakModel(),
  );

  StreakService(this._source);

  Future<void> refresh() async {
    final model = await _source.getStreak();
    streak$.add(model);
  }

  Future<void> recordReading() async {
    final current = await _source.getStreak();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (current.lastReadDate != null) {
      final lastDate = DateTime(
        current.lastReadDate!.year,
        current.lastReadDate!.month,
        current.lastReadDate!.day,
      );
      if (lastDate == todayDate) {
        // Already recorded today
        return;
      }

      final difference = todayDate.difference(lastDate).inDays;
      if (difference == 1) {
        // Consecutive day
        final newStreak = current.currentStreak + 1;
        final longest = newStreak > current.longestStreak
            ? newStreak
            : current.longestStreak;
        await _source.saveStreak(
          current.copyWith(
            currentStreak: newStreak,
            longestStreak: longest,
            lastReadDate: todayDate,
            weeklyActivity: _updateWeeklyActivity(todayDate),
            totalReadingDays: current.totalReadingDays + 1,
            milestoneLabel: _milestoneFor(newStreak),
          ),
        );
      } else {
        // Streak broken
        await _source.saveStreak(
          current.copyWith(
            currentStreak: 1,
            lastReadDate: todayDate,
            weeklyActivity: _updateWeeklyActivity(todayDate),
            totalReadingDays: current.totalReadingDays + 1,
            milestoneLabel: null,
          ),
        );
      }
    } else {
      // First ever reading
      await _source.saveStreak(
        current.copyWith(
          currentStreak: 1,
          longestStreak: 1,
          lastReadDate: todayDate,
          weeklyActivity: _updateWeeklyActivity(todayDate),
          totalReadingDays: 1,
        ),
      );
    }

    await refresh();
  }

  List<bool> _updateWeeklyActivity(DateTime today) {
    final weekday = today.weekday - 1; // 0=Mon, 6=Sun
    final activity = List<bool>.filled(7, false);
    activity[weekday] = true;

    // Only preserve other days if lastReadDate is in the same week
    final current = streak$.value;
    if (current.lastReadDate != null) {
      final lastDate = current.lastReadDate!;
      // Find the Monday of the current week
      final todayMondayOffset = today.weekday - 1;
      final thisMonday = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: todayMondayOffset));
      // Find the Monday of the last read week
      final lastMondayOffset = lastDate.weekday - 1;
      final lastMonday = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      ).subtract(Duration(days: lastMondayOffset));

      if (thisMonday == lastMonday) {
        // Same week — preserve existing activity
        for (int i = 0; i < 7; i++) {
          if (i != weekday && i < current.weeklyActivity.length) {
            activity[i] = current.weeklyActivity[i];
          }
        }
      }
      // Different week — start fresh (activity is already all false except today)
    }
    return activity;
  }

  String? _milestoneFor(int streak) {
    String? label;
    for (final entry in AppConstants.streakMilestones.entries) {
      if (streak >= entry.key) label = entry.value;
    }
    return label;
  }
}
