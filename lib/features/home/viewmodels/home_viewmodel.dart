import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/celebration_service.dart';
import 'package:readline_app/core/services/share_card_service.dart';
import 'package:readline_app/core/services/streak_service.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

/// What action the home featured-document card should suggest.
enum HomeFeatureMode { continueReading, startNew, readAgain }

/// Pre-computed featured-card display data — moves estimation math out of the widget.
class FeaturedDocument {
  final DocumentModel document;
  final HomeFeatureMode mode;
  final double progress;
  final int estimatedMinutes;

  const FeaturedDocument({
    required this.document,
    required this.mode,
    required this.progress,
    required this.estimatedMinutes,
  });
}

class HomeStats {
  final int totalDocs;
  final int avgSpeedWpm;
  final int savedSpeedWpm;
  final int totalWordsRead;
  final double todayMinutes;
  final int dailyGoalMinutes;
  final String userName;

  const HomeStats({
    this.totalDocs = 0,
    this.avgSpeedWpm = 0,
    this.savedSpeedWpm = 0,
    this.totalWordsRead = 0,
    this.todayMinutes = 0,
    this.dailyGoalMinutes = 20,
    this.userName = '',
  });
}

class HomeViewModel {
  final DocumentRepository _docRepo;
  final SessionRepository _sessionRepo;
  final PreferencesRepository _prefsRepo;
  final StreakService _streakService;
  final CelebrationService _celebrationService;
  final ShareCardService _shareCardService;
  bool _celebrationStartupChecked = false;

  final BehaviorSubject<List<DocumentModel>> documents$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<FeaturedDocument?> featured$ = BehaviorSubject.seeded(
    null,
  );
  final BehaviorSubject<List<ReadingSessionModel>> recentSessions$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<StreakModel> streak$ = BehaviorSubject.seeded(
    const StreakModel(),
  );
  final BehaviorSubject<HomeStats> stats$ = BehaviorSubject.seeded(
    const HomeStats(),
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(true);
  final BehaviorSubject<bool> streakJustBroke$ = BehaviorSubject.seeded(false);

  HomeViewModel({
    DocumentRepository? docRepo,
    SessionRepository? sessionRepo,
    PreferencesRepository? prefsRepo,
    StreakService? streakService,
    CelebrationService? celebrationService,
    ShareCardService? shareCardService,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _streakService = streakService ?? getIt<StreakService>(),
       _celebrationService =
           celebrationService ?? getIt<CelebrationService>(),
       _shareCardService = shareCardService ?? getIt<ShareCardService>();

  Stream<CelebrationData?> get pendingCelebration$ =>
      _celebrationService.pendingCelebration$;

  Future<void> init() async {
    _celebrationService.startListening();
    await refresh();
    _runStartupCelebrationChecks();
  }

  void _runStartupCelebrationChecks() {
    if (_celebrationStartupChecked) return;
    _celebrationStartupChecked = true;
    _celebrationService.checkDailyTarget();
    _celebrationService.checkWordsMilestone(stats$.value.totalWordsRead);
  }

  void clearPendingCelebration() => _celebrationService.clearPending();

  Future<void> shareCelebration(GlobalKey shareKey) =>
      _shareCardService.captureAndShare(shareKey);

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      await _streakService.refresh();

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final results = await Future.wait([
        _docRepo.getAll(),
        _sessionRepo.getRecent(5),
        _sessionRepo.getByDateRange(todayStart, tomorrowStart),
        _prefsRepo.get(),
      ]);

      final docs = results[0] as List<DocumentModel>;
      final recentSessions = results[1] as List<ReadingSessionModel>;
      final todaySessions = results[2] as List<ReadingSessionModel>;
      final prefs = results[3] as UserPreferencesModel;

      documents$.add(docs);
      recentSessions$.add(recentSessions);
      streak$.add(_streakService.streak$.value);
      streakJustBroke$.add(_streakService.streak$.value.streakJustBroke);

      // Resolve featured document by priority:
      //   1. In-progress (most recently read) → continue
      //   2. Unread (most recently imported)  → start new
      //   3. Completed (most recently read)   → read again
      DocumentModel? featured;
      var mode = HomeFeatureMode.continueReading;
      if (docs.isNotEmpty) {
        DateTime ts(DocumentModel d) => d.lastReadAt ?? d.importedAt;
        final inProgress = docs.where((d) => d.isInProgress).toList()
          ..sort((a, b) => ts(b).compareTo(ts(a)));
        if (inProgress.isNotEmpty) {
          featured = inProgress.first;
          mode = HomeFeatureMode.continueReading;
        } else {
          final unread = docs.where((d) => d.isUnread && !d.isCompleted).toList()
            ..sort((a, b) => ts(b).compareTo(ts(a)));
          if (unread.isNotEmpty) {
            featured = unread.first;
            mode = HomeFeatureMode.startNew;
          } else {
            final completed = docs.where((d) => d.isCompleted).toList()
              ..sort((a, b) => ts(b).compareTo(ts(a)));
            if (completed.isNotEmpty) {
              featured = completed.first;
              mode = HomeFeatureMode.readAgain;
            }
          }
        }
      }
      // Today's reading minutes — from ALL sessions today, not just recent 5
      final todayMinutes = todaySessions.fold<double>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );

      // Compute stats
      final totalWordsRead = docs.fold<int>(0, (sum, d) => sum + d.wordsRead);
      final avgWpm = recentSessions.isEmpty
          ? prefs.readingSpeedWpm
          : (recentSessions.fold<int>(0, (s, r) => s + r.averageWpm) ~/
                recentSessions.length);

      stats$.add(
        HomeStats(
          totalDocs: docs.length,
          avgSpeedWpm: avgWpm,
          savedSpeedWpm: prefs.readingSpeedWpm,
          totalWordsRead: totalWordsRead,
          todayMinutes: todayMinutes,
          dailyGoalMinutes: prefs.dailyGoalMinutes,
          userName: prefs.userName,
        ),
      );

      // Pre-compute featured-card display data so the widget stays UI-only.
      featured$.add(
        _buildFeatured(
          featured,
          mode,
          savedWpm: prefs.readingSpeedWpm,
          avgWpm: avgWpm,
        ),
      );
    } finally {
      isLoading$.add(false);
    }
  }

  FeaturedDocument? _buildFeatured(
    DocumentModel? doc,
    HomeFeatureMode mode, {
    required int savedWpm,
    required int avgWpm,
  }) {
    if (doc == null) return null;
    final wpm = savedWpm > 0 ? savedWpm : avgWpm;
    final isFresh =
        mode == HomeFeatureMode.startNew || mode == HomeFeatureMode.readAgain;

    final progress = isFresh
        ? 0.0
        : (doc.totalWords > 0
              ? (doc.wordsRead / doc.totalWords).clamp(0.0, 1.0)
              : 0.0);

    int minutes;
    if (isFresh) {
      minutes = (doc.totalWords <= 0 || wpm <= 0)
          ? 0
          : (doc.totalWords / wpm).ceil();
    } else {
      final wordsLeft = doc.totalWords - doc.wordsRead;
      minutes = (wordsLeft <= 0 || wpm <= 0) ? 0 : (wordsLeft / wpm).ceil();
    }

    return FeaturedDocument(
      document: doc,
      mode: mode,
      progress: progress,
      estimatedMinutes: minutes,
    );
  }

  Future<void> clearStreakBroke() async {
    await _streakService.clearStreakJustBroke();
    streakJustBroke$.add(false);
  }

  Future<void> updateDailyGoal(int minutes) async {
    final prefs = await _prefsRepo.get();
    await _prefsRepo.save(prefs.copyWith(dailyGoalMinutes: minutes));
    await refresh();
  }

  void dispose() {
    documents$.close();
    featured$.close();
    recentSessions$.close();
    streak$.close();
    stats$.close();
    isLoading$.close();
    streakJustBroke$.close();
  }
}
