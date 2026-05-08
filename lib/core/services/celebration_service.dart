import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:readline_app/core/services/streak_service.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/datasources/local/hive_milestone_source.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/data/models/milestone_model.dart';
import 'package:readline_app/data/models/streak_model.dart';

class CelebrationService {
  final StreakService _streakService;
  final SessionRepository _sessionRepo;
  final PreferencesRepository _prefsRepo;
  final HiveMilestoneSource? _milestoneSource;

  final BehaviorSubject<CelebrationData?> pendingCelebration$ =
      BehaviorSubject.seeded(null);

  StreamSubscription<StreakModel>? _streakSub;
  final Set<String> _shownCelebrations = {};

  static const List<int> wordMilestones = [1000, 5000, 10000, 50000, 100000];

  static const _uuid = Uuid();

  CelebrationService(
    this._streakService,
    this._sessionRepo,
    this._prefsRepo, [
    this._milestoneSource,
  ]);

  Future<void> startListening() async {
    if (_streakSub != null) return;
    await _loadPersistedCelebrations();
    _streakSub = _streakService.streak$.listen(_onStreakChanged);
  }

  Future<void> _loadPersistedCelebrations() async {
    try {
      final prefs = await _prefsRepo.get();
      _shownCelebrations.addAll(prefs.celebratedMilestones);
    } catch (_) {
      // Best-effort — start with empty set on failure
    }
  }

  Future<void> _persistCelebration(String key) async {
    try {
      final prefs = await _prefsRepo.get();
      final updated = prefs.copyWith(
        celebratedMilestones: [...prefs.celebratedMilestones, key],
      );
      await _prefsRepo.save(updated);
    } catch (_) {
      // Best-effort — celebration still shown even if persist fails
    }
  }

  Future<void> _saveMilestone({
    required String type,
    required int value,
    required String description,
  }) async {
    try {
      await _milestoneSource?.save(
        MilestoneModel(
          id: _uuid.v4(),
          type: type,
          value: value,
          date: DateTime.now(),
          description: description,
        ),
      );
    } catch (_) {
      // Best-effort
    }
  }

  void _onStreakChanged(StreakModel streak) {
    if (streak.currentStreak > 0 && isMilestone(streak.currentStreak)) {
      final key = 'streak_${streak.currentStreak}';
      if (!_shownCelebrations.contains(key)) {
        _shownCelebrations.add(key);
        _persistCelebration(key);
        _saveMilestone(
          type: 'streak',
          value: streak.currentStreak,
          description: '${streak.currentStreak} day streak',
        );
        final tier = CelebrationData.tierForStreak(streak.currentStreak);
        pendingCelebration$.add(
          CelebrationData(
            type: CelebrationType.streakMilestone,
            tier: tier,
            streakCount: streak.currentStreak,
            titleKey: 'celebration.streakTitle',
            messageKey: 'celebration.streakMessage',
          ),
        );
      }
    }
  }

  /// Check if daily target was just met
  Future<void> checkDailyTarget() async {
    try {
      final prefs = await _prefsRepo.get();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      final sessions = await _sessionRepo.getByDateRange(
        todayStart,
        tomorrowStart,
      );
      final todayMinutes = sessions.fold<double>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );

      if (todayMinutes >= prefs.dailyGoalMinutes) {
        final key = 'daily_${todayStart.toIso8601String()}';
        if (!_shownCelebrations.contains(key)) {
          _shownCelebrations.add(key);
          _persistCelebration(key);

          // Check if also streak milestone — if so, use streak visual
          final streak = _streakService.streak$.value;
          if (streak.currentStreak > 0 && isMilestone(streak.currentStreak)) {
            final streakKey = 'streak_${streak.currentStreak}';
            if (!_shownCelebrations.contains(streakKey)) {
              _shownCelebrations.add(streakKey);
              _persistCelebration(streakKey);
              // Combined: use streak milestone visual with daily target subtitle
              pendingCelebration$.add(
                CelebrationData(
                  type: CelebrationType.streakMilestone,
                  tier: CelebrationData.tierForStreak(streak.currentStreak),
                  streakCount: streak.currentStreak,
                  minutesRead: todayMinutes,
                  titleKey: 'celebration.streakTitle',
                  messageKey: 'celebration.combinedMessage',
                ),
              );
              return;
            }
          }

          _saveMilestone(
            type: 'daily_target',
            value: todayMinutes.round(),
            description: 'Daily goal reached',
          );
          pendingCelebration$.add(
            CelebrationData(
              type: CelebrationType.dailyTarget,
              tier: CelebrationTier.gold,
              minutesRead: todayMinutes,
              titleKey: 'celebration.dailyTargetTitle',
              messageKey: 'celebration.dailyTargetMessage',
            ),
          );
        }
      }
    } catch (_) {
      // Best-effort
    }
  }

  /// Check word count milestones
  Future<void> checkWordsMilestone(int totalWordsRead) async {
    for (final milestone in wordMilestones) {
      if (totalWordsRead >= milestone) {
        final key = 'words_$milestone';
        if (!_shownCelebrations.contains(key)) {
          _shownCelebrations.add(key);
          _persistCelebration(key);
          _saveMilestone(
            type: 'words',
            value: milestone,
            description: '$milestone words read',
          );
          pendingCelebration$.add(
            CelebrationData(
              type: CelebrationType.wordsMilestone,
              tier: CelebrationData.tierForWords(milestone),
              wordsCount: milestone,
              titleKey: 'celebration.wordsTitle',
              messageKey: 'celebration.wordsMessage',
            ),
          );
          break; // Show only one milestone at a time
        }
      }
    }
  }

  void clearPending() {
    pendingCelebration$.add(null);
  }

  /// Streak celebration milestones: 1, 3, 7, 14, 21, 28, ...
  /// Mirrors the padlock app's milestone schedule.
  static bool isMilestone(int streak) {
    if (streak <= 0) return false;
    if (streak == 1 || streak == 3) return true;
    return streak >= 7 && streak % 7 == 0;
  }

  void dispose() {
    _streakSub?.cancel();
    pendingCelebration$.close();
  }
}
