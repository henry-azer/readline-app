import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:readline_app/core/services/streak_service.dart';
import 'package:readline_app/data/datasources/local/hive_streak_source.dart';
import 'package:readline_app/data/models/streak_model.dart';

void main() {
  late Directory tempDir;
  late HiveStreakSource source;
  late StreakService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('streak_test');
    Hive.init(tempDir.path);
    source = HiveStreakSource();
    service = StreakService(source);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  // ---------------------------------------------------------------------------
  // First reading
  // ---------------------------------------------------------------------------
  group('first ever reading', () {
    test('starts streak at 1', () async {
      await service.recordReading();
      final streak = service.streak$.value;
      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
      expect(streak.totalReadingDays, 1);
    });

    test('sets lastReadDate to today', () async {
      await service.recordReading();
      final streak = service.streak$.value;
      final today = DateTime.now();
      expect(streak.lastReadDate?.year, today.year);
      expect(streak.lastReadDate?.month, today.month);
      expect(streak.lastReadDate?.day, today.day);
    });
  });

  // ---------------------------------------------------------------------------
  // Same-day duplicate
  // ---------------------------------------------------------------------------
  group('same-day duplicate', () {
    test('calling recordReading twice on the same day is idempotent', () async {
      await service.recordReading();
      await service.recordReading();
      final streak = service.streak$.value;
      expect(streak.currentStreak, 1);
      expect(streak.totalReadingDays, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // Consecutive day (simulated by saving state directly)
  // ---------------------------------------------------------------------------
  group('consecutive day', () {
    test('increments streak when last read was yesterday', () async {
      // Save a state that says the user last read yesterday.
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      await source.saveStreak(
        StreakModel(
          currentStreak: 3,
          longestStreak: 5,
          lastReadDate: yesterdayDate,
          totalReadingDays: 10,
        ),
      );
      await service.refresh();
      await service.recordReading();
      final streak = service.streak$.value;
      expect(streak.currentStreak, 4);
      expect(streak.longestStreak, 5); // was already higher
      expect(streak.totalReadingDays, 11);
    });

    test('updates longestStreak when new streak exceeds it', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      await source.saveStreak(
        StreakModel(
          currentStreak: 6,
          longestStreak: 6,
          lastReadDate: yesterdayDate,
          totalReadingDays: 6,
        ),
      );
      await service.refresh();
      await service.recordReading();
      final streak = service.streak$.value;
      expect(streak.currentStreak, 7);
      expect(streak.longestStreak, 7);
    });
  });

  // ---------------------------------------------------------------------------
  // Skipped day (streak broken)
  // ---------------------------------------------------------------------------
  group('skipped day', () {
    test('resets streak to 1 when last read was 2+ days ago', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoDate = DateTime(
        twoDaysAgo.year,
        twoDaysAgo.month,
        twoDaysAgo.day,
      );
      await source.saveStreak(
        StreakModel(
          currentStreak: 10,
          longestStreak: 10,
          lastReadDate: twoDaysAgoDate,
          totalReadingDays: 10,
        ),
      );
      await service.refresh();
      await service.recordReading();
      final streak = service.streak$.value;
      expect(streak.currentStreak, 1);
      expect(streak.totalReadingDays, 11);
    });

    test('longestStreak is preserved after streak reset', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoDate = DateTime(
        twoDaysAgo.year,
        twoDaysAgo.month,
        twoDaysAgo.day,
      );
      await source.saveStreak(
        StreakModel(
          currentStreak: 4,
          longestStreak: 15,
          lastReadDate: twoDaysAgoDate,
          totalReadingDays: 20,
        ),
      );
      await service.refresh();
      await service.recordReading();
      final streak = service.streak$.value;
      // longestStreak must NOT decrease on a reset
      expect(streak.longestStreak, 15);
    });
  });

  // ---------------------------------------------------------------------------
  // Longest streak tracking
  // ---------------------------------------------------------------------------
  group('longest streak', () {
    test(
      'longest streak is tracked correctly across consecutive days',
      () async {
        // Simulate 6 consecutive days already recorded.
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        await source.saveStreak(
          StreakModel(
            currentStreak: 6,
            longestStreak: 6,
            lastReadDate: yesterdayDate,
            totalReadingDays: 6,
          ),
        );
        await service.refresh();
        await service.recordReading();
        expect(service.streak$.value.longestStreak, 7);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Weekly activity
  // ---------------------------------------------------------------------------
  group('weekly activity', () {
    test('marks the correct weekday in the activity list', () async {
      await service.recordReading();
      final streak = service.streak$.value;
      final today = DateTime.now();
      final weekdayIndex = today.weekday - 1; // 0=Mon, 6=Sun
      expect(streak.weeklyActivity[weekdayIndex], isTrue);
    });

    test('weekly activity list always has 7 elements', () async {
      await service.recordReading();
      expect(service.streak$.value.weeklyActivity.length, 7);
    });
  });

  // ---------------------------------------------------------------------------
  // Milestone labels
  // ---------------------------------------------------------------------------
  group('milestone labels', () {
    Future<void> setStreakAndRecord(int currentStreak) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      await source.saveStreak(
        StreakModel(
          currentStreak: currentStreak,
          longestStreak: currentStreak,
          lastReadDate: yesterdayDate,
          totalReadingDays: currentStreak,
        ),
      );
      await service.refresh();
      await service.recordReading();
    }

    test('streak 7 → milestone "on fire"', () async {
      await setStreakAndRecord(6); // recording will make it 7
      expect(service.streak$.value.milestoneLabel, 'on fire');
    });

    test('streak 14 → milestone "unstoppable"', () async {
      await setStreakAndRecord(13);
      expect(service.streak$.value.milestoneLabel, 'unstoppable');
    });

    test('streak 30 → milestone "legendary"', () async {
      await setStreakAndRecord(29);
      expect(service.streak$.value.milestoneLabel, 'legendary');
    });

    test('streak 100 → milestone "archivist"', () async {
      await setStreakAndRecord(99);
      expect(service.streak$.value.milestoneLabel, 'archivist');
    });

    test('streak below 7 has no milestone', () async {
      await service.recordReading(); // streak = 1, no milestone
      expect(service.streak$.value.milestoneLabel, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // refresh
  // ---------------------------------------------------------------------------
  group('refresh', () {
    test('refresh loads persisted data into stream', () async {
      await source.saveStreak(
        const StreakModel(currentStreak: 42, longestStreak: 42),
      );
      await service.refresh();
      expect(service.streak$.value.currentStreak, 42);
    });
  });
}
