import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/data/datasources/local/hive_streak_source.dart';
import 'package:readline_app/data/models/streak_model.dart';

class StreakService {
  final HiveStreakSource _source;

  final BehaviorSubject<StreakModel> streak$ = BehaviorSubject.seeded(
    const StreakModel(),
  );

  StreakService(this._source);

  Future<void> refresh() async {
    var model = await _source.getStreak();

    // Check if the streak is stale — broken if lastReadDate is >1 day ago
    if (model.currentStreak > 0 && model.lastReadDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDate = DateTime(
        model.lastReadDate!.year,
        model.lastReadDate!.month,
        model.lastReadDate!.day,
      );
      final gap = _calendarDaysBetween(lastDate, today);

      if (gap > 1) {
        // Streak broken — save to history before resetting
        final updatedHistory = [...model.streakHistory];
        if (model.currentStreak > 0 && model.lastReadDate != null) {
          final startDate = model.lastReadDate!.subtract(
            Duration(days: model.currentStreak - 1),
          );
          updatedHistory.add(
            StreakHistoryEntry(
              startDate: startDate,
              endDate: model.lastReadDate!,
              length: model.currentStreak,
            ),
          );
        }
        model = model.copyWith(
          currentStreak: 0,
          milestoneLabel: null,
          weeklyActivity: _freshWeeklyActivity(today, model),
          streakHistory: updatedHistory,
          streakJustBroke: true,
        );
        await _source.saveStreak(model);
      } else if (gap == 1 || gap == 0) {
        // Still valid (today or yesterday) — refresh weekly if new week
        final todayMonday = today.subtract(Duration(days: today.weekday - 1));
        final lastMonday = lastDate.subtract(
          Duration(days: lastDate.weekday - 1),
        );
        if (todayMonday != lastMonday) {
          // New week — clear weekly activity but keep streak
          model = model.copyWith(
            weeklyActivity: gap == 0
                ? _freshWeeklyActivity(today, null)
                : const [false, false, false, false, false, false, false],
          );
          await _source.saveStreak(model);
        }
      }
    }

    streak$.add(model);
  }

  /// Build a fresh weekly activity list, preserving today if needed.
  List<bool> _freshWeeklyActivity(DateTime today, StreakModel? preserve) {
    final activity = List<bool>.filled(7, false);
    // If preserving and same week, keep prior days
    if (preserve != null && preserve.lastReadDate != null) {
      final lastDate = preserve.lastReadDate!;
      final todayMonday = today.subtract(Duration(days: today.weekday - 1));
      final lastMonday = lastDate.subtract(
        Duration(days: lastDate.weekday - 1),
      );
      if (todayMonday == lastMonday) {
        for (int i = 0; i < 7 && i < preserve.weeklyActivity.length; i++) {
          activity[i] = preserve.weeklyActivity[i];
        }
      }
    }
    return activity;
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

      final difference = _calendarDaysBetween(lastDate, todayDate);
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
        // Streak broken — save to history before resetting
        final updatedHistory = [...current.streakHistory];
        if (current.currentStreak > 0 && current.lastReadDate != null) {
          final startDate = current.lastReadDate!.subtract(
            Duration(days: current.currentStreak - 1),
          );
          updatedHistory.add(
            StreakHistoryEntry(
              startDate: startDate,
              endDate: current.lastReadDate!,
              length: current.currentStreak,
            ),
          );
        }
        await _source.saveStreak(
          current.copyWith(
            currentStreak: 1,
            lastReadDate: todayDate,
            weeklyActivity: _updateWeeklyActivity(todayDate),
            totalReadingDays: current.totalReadingDays + 1,
            milestoneLabel: null,
            streakHistory: updatedHistory,
            streakJustBroke: true,
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

  /// Clear the streak-just-broke flag after the banner has been shown.
  Future<void> clearStreakJustBroke() async {
    final current = await _source.getStreak();
    if (current.streakJustBroke) {
      final updated = current.copyWith(streakJustBroke: false);
      await _source.saveStreak(updated);
      streak$.add(updated);
    }
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

  /// Calendar-day difference immune to DST shifts.
  static int _calendarDaysBetween(DateTime a, DateTime b) {
    return DateTime.utc(
      b.year,
      b.month,
      b.day,
    ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  }

  String? _milestoneFor(int streak) {
    String? label;
    for (final entry in AppConstants.streakMilestones.entries) {
      if (streak >= entry.key) label = entry.value;
    }
    return label;
  }
}
