import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/services/reading_engine_service.dart';
import 'package:read_it/core/services/streak_service.dart';
import 'package:read_it/core/services/vocabulary_service.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/contracts/session_repository.dart';
import 'package:read_it/data/entities/reading_state.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/data/models/user_preferences_model.dart';

class ReadingViewModel {
  static const _uuid = Uuid();
  static const _autoSaveInterval = Duration(seconds: 30);
  static const _idleTimeout = Duration(seconds: 60);
  static const _backgroundTimeout = Duration(minutes: 5);

  /// Cumulative active-reading time required before today's streak is counted.
  static const _streakThreshold = Duration(seconds: 10);

  final String documentId;
  final bool restart;

  final DocumentRepository _docRepo;
  final PreferencesRepository _prefsRepo;
  final SessionRepository _sessionRepo;
  final StreakService _streakService;
  final ReadingEngineService _engine;
  final VocabularyService _vocabService;

  final BehaviorSubject<DocumentModel?> document$ = BehaviorSubject.seeded(
    null,
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(true);
  final BehaviorSubject<StreakModel> streak$ = BehaviorSubject.seeded(
    const StreakModel(),
  );
  final BehaviorSubject<int> wordsCollected$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<bool> sessionSaved$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> error$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<UserPreferencesModel?> preferences$ =
      BehaviorSubject.seeded(null);

  // Direct access to engine state for StreamBuilder
  Stream<ReadingState> get readingState$ => _engine.state$.stream;

  ReadingSessionModel? _session;
  DateTime? _sessionStartTime;
  int _startWordIndex = 0;
  bool _isClosed = false;
  Timer? _autoSaveTimer;
  Timer? _idleTimer;
  Timer? _backgroundTimer;
  Timer? _streakThresholdTimer;
  Duration _activeReadingTime = Duration.zero;
  bool _streakRecordedThisSession = false;
  DateTime? _pausedAt;
  bool _wasPlayingBeforePause = false;

  ReadingViewModel({
    required this.documentId,
    this.restart = false,
    DocumentRepository? docRepo,
    PreferencesRepository? prefsRepo,
    SessionRepository? sessionRepo,
    StreakService? streakService,
    ReadingEngineService? engine,
    VocabularyService? vocabService,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _streakService = streakService ?? getIt<StreakService>(),
       _engine = engine ?? getIt<ReadingEngineService>(),
       _vocabService = vocabService ?? getIt<VocabularyService>();

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> init() async {
    isLoading$.add(true);
    error$.add(null);
    try {
      final results = await Future.wait([
        _docRepo.getById(documentId),
        _prefsRepo.get(),
        _streakService.refresh(),
      ]);

      var doc = results[0] as DocumentModel?;
      final prefs = results[1] as UserPreferencesModel;

      if (doc == null) {
        error$.add(AppStrings.errorDocumentNotFound.tr);
        return;
      }

      // Re-read flow: caller asked to restart from the beginning.
      // Also auto-restart when the document is already completed and the
      // saved position is at the end — otherwise the user would land on a
      // useless empty tail.
      final shouldRestart = restart || (doc.isCompleted && doc.wordsRead >= doc.totalWords);
      if (shouldRestart) {
        await _docRepo.resetProgress(doc.id);
        doc = doc.copyWith(
          currentPage: 0,
          wordsRead: 0,
          readingStatus: 'reading',
          lastReadAt: DateTime.now(),
        );
      }

      document$.add(doc);
      preferences$.add(prefs);
      streak$.add(_streakService.streak$.value);

      // Load content into engine
      _engine.loadContent(
        doc.extractedText.isEmpty ? _sampleText : doc.extractedText,
        wpm: prefs.readingSpeedWpm,
        focusLines: prefs.focusWindowLines,
      );

      // Resume from last position if available
      if (doc.wordsRead > 0) {
        _engine.resumeFromPosition(doc.wordsRead);
      }
      _startWordIndex = _engine.currentWordIndex;
    } catch (e) {
      error$.add(AppStrings.errorFailedToLoad.tr);
    } finally {
      isLoading$.add(false);
    }
  }

  // ── Playback controls ──────────────────────────────────────────────────────

  void togglePlayPause() {
    final isPlaying = _engine.state$.value.isPlaying;
    if (isPlaying) {
      _engine.pause();
      _stopAutoSave();
    } else {
      _ensureSessionStarted();
      _engine.play();
      _startAutoSave();
      _startStreakThresholdTimer();
      _resetIdleTimer();
    }
  }

  /// Called by the screen when user interacts (tap, scroll, etc.)
  void recordInteraction() {
    _resetIdleTimer();
  }

  /// Called when app goes to background.
  /// Starts a 5-minute timeout; if exceeded, the session ends automatically.
  Future<void> onAppPaused() async {
    _wasPlayingBeforePause = _engine.state$.value.isPlaying;
    if (_wasPlayingBeforePause) {
      _engine.pause();
    }
    _pausedAt = DateTime.now();
    _stopAutoSave();

    await _autoSavePartialSession();

    // Start 5-minute background timeout
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer(_backgroundTimeout, _onBackgroundTimeout);
  }

  /// Called when app comes back to foreground.
  /// If within 5 minutes, continues the session. Otherwise starts fresh.
  void onAppResumed() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    if (_pausedAt != null) {
      final elapsed = DateTime.now().difference(_pausedAt!);
      _pausedAt = null;

      if (elapsed >= _backgroundTimeout) {
        // Timeout exceeded — end current session, start a new one on next play
        _endSessionForTimeout();
        return;
      }
    }

    // Within 5 minutes — resume normally
    if (_session != null && _wasPlayingBeforePause) {
      _engine.play();
      _startAutoSave();
    }
  }

  void _onBackgroundTimeout() {
    // App was in background for >5 minutes
    _endSessionForTimeout();
  }

  void _endSessionForTimeout() {
    if (_session == null || sessionSaved$.value) return;

    // Finalize the current session silently
    final doc = document$.valueOrNull;
    if (doc == null) return;

    final now = DateTime.now();
    final wordsRead = _engine.currentWordIndex - _startWordIndex;
    final durationMs = (_pausedAt ?? now)
        .difference(_sessionStartTime!)
        .inMilliseconds;
    final durationMinutes = durationMs / 60000.0;
    final avgWpm = durationMinutes > 0
        ? (wordsRead / durationMinutes).round()
        : _engine.currentWpm;

    final finalSession = _session!.copyWith(
      endedAt: _pausedAt ?? now,
      durationMinutes: durationMinutes,
      wordsRead: wordsRead.clamp(0, _engine.totalWords),
      averageWpm: avgWpm,
      endPage: doc.currentPage,
      focusScore: _engine.calculateFocusScore(),
      wordsCollected: wordsCollected$.value,
      performanceLabel: _performanceLabel(avgWpm, doc.complexityLevel),
    );

    _sessionRepo
        .save(finalSession)
        .then((_) {
          _docRepo.updateProgress(
            doc.id,
            doc.currentPage,
            _progressIndex,
          );
          _checkAndIncrementStreak();
        })
        .catchError((_) {});

    // Reset for a fresh session on next play
    _session = null;
    _sessionStartTime = null;
    _startWordIndex = _engine.currentWordIndex;
    sessionSaved$.add(false);
    _wasPlayingBeforePause = false;
  }

  void adjustSpeed(int wpm) {
    _engine.setSpeed(wpm);
    _updatePref((p) => p.copyWith(readingSpeedWpm: wpm));
  }

  void updateFontSize(int size) {
    _updatePref((p) => p.copyWith(fontSize: size));
  }

  void updateLineSpacing(double spacing) {
    _updatePref((p) => p.copyWith(lineSpacing: spacing));
  }

  void updateFocusLines(int lines) {
    _engine.setFocusLines(lines);
    _updatePref((p) => p.copyWith(focusWindowLines: lines));
  }

  void updateFontFamily(String family) {
    _updatePref((p) => p.copyWith(fontFamily: family));
  }

  void toggleVocabCollection() {
    final current = preferences$.valueOrNull;
    if (current == null) return;
    _updatePref(
      (p) => p.copyWith(enableVocabCollection: !p.enableVocabCollection),
    );
  }

  void updateTextAlignment(String alignment) {
    _updatePref((p) => p.copyWith(textAlignment: alignment));
  }

  void toggleAutoPlay() {
    final current = preferences$.valueOrNull;
    if (current == null) return;
    _updatePref((p) => p.copyWith(autoPlayOnOpen: !p.autoPlayOnOpen));
  }

  void updateReadingBackground(String bg) {
    _updatePref((p) => p.copyWith(readingBackground: bg));
  }

  void updateReadingFontColor(String color) {
    _updatePref((p) => p.copyWith(readingFontColor: color));
  }

  void toggleBold() {
    final c = preferences$.valueOrNull;
    if (c == null) return;
    _updatePref((p) => p.copyWith(readingBold: !p.readingBold));
  }

  void toggleItalic() {
    final c = preferences$.valueOrNull;
    if (c == null) return;
    _updatePref((p) => p.copyWith(readingItalic: !p.readingItalic));
  }

  void toggleUnderline() {
    final c = preferences$.valueOrNull;
    if (c == null) return;
    _updatePref((p) => p.copyWith(readingUnderline: !p.readingUnderline));
  }

  void updateLetterSpacing(String spacing) {
    _updatePref((p) => p.copyWith(letterSpacing: spacing));
  }

  void updateReadingTheme(String theme) {
    _updatePref((p) => p.copyWith(readingTheme: theme));
  }

  void updateReadingMargin(double margin) {
    _updatePref((p) => p.copyWith(readingMargin: margin));
  }

  void updateBrightnessOverlay(double value) {
    _updatePref((p) => p.copyWith(brightnessOverlay: value));
  }

  void updateBrightnessLevel(double value) {
    _updatePref((p) => p.copyWith(brightnessLevel: value));
  }

  void _updatePref(
    UserPreferencesModel Function(UserPreferencesModel) updater,
  ) {
    final current = preferences$.valueOrNull;
    if (current == null) return;
    final updated = updater(current);
    preferences$.add(updated);
    _prefsRepo.save(updated);
  }

  void jumpToWord(int index) {
    _engine.jumpToWord(index);
  }

  void highlightWord(String? word) {
    _engine.highlightWord(word);
  }

  /// The word index to persist as progress. When the engine has reached the
  /// end the index plateaus at `totalWords - 1`, but the repo only flips
  /// status to `completed` when `wordsRead >= totalWords` — so we boost it
  /// to the full count when [ReadingState.isComplete] is set.
  int get _progressIndex {
    final state = _engine.state$.value;
    if (state.isComplete) return _engine.totalWords;
    return _engine.currentWordIndex;
  }

  // ── Session lifecycle ──────────────────────────────────────────────────────

  void _ensureSessionStarted() {
    if (_session != null) return;
    final doc = document$.valueOrNull;
    if (doc == null) return;

    _sessionStartTime = DateTime.now();
    _session = ReadingSessionModel(
      id: _uuid.v4(),
      documentId: doc.id,
      documentTitle: doc.title,
      startedAt: _sessionStartTime!,
    );
  }

  Future<void> saveSession() async {
    final doc = document$.valueOrNull;
    if (_isClosed || doc == null || _session == null || sessionSaved$.value) {
      _engine.stop();
      return;
    }
    _engine.stop();

    final now = DateTime.now();
    final wordsRead = _engine.currentWordIndex - _startWordIndex;
    final durationMs = now.difference(_sessionStartTime!).inMilliseconds;
    final durationMinutes = durationMs / 60000.0;
    final avgWpm = durationMinutes > 0
        ? (wordsRead / durationMinutes).round()
        : _engine.currentWpm;
    final focusScore = _engine.calculateFocusScore();
    final perfLabel = _performanceLabel(avgWpm, doc.complexityLevel);

    final finalSession = _session!.copyWith(
      endedAt: now,
      durationMinutes: durationMinutes,
      wordsRead: wordsRead.clamp(0, _engine.totalWords),
      averageWpm: avgWpm,
      endPage: doc.currentPage,
      focusScore: focusScore,
      wordsCollected: wordsCollected$.value,
      performanceLabel: perfLabel,
    );

    try {
      await _sessionRepo.save(finalSession);

      // Update document progress
      await _docRepo.updateProgress(
        doc.id,
        doc.currentPage,
        _progressIndex,
      );

      // Check daily target completion for streak increment
      await _checkAndIncrementStreak();

      _session = finalSession;
      sessionSaved$.add(true);
    } catch (_) {
      // Best-effort save — do not surface error on exit
    }
  }

  Future<void> saveWordToVocabulary(String word) async {
    final doc = document$.valueOrNull;
    if (doc == null) return;

    final state = _engine.state$.value;
    final context = state.focusText.isNotEmpty ? state.focusText : word;

    try {
      await _vocabService.saveWord(
        word: word,
        contextSentence: context,
        sourceDocumentId: doc.id,
        sourceDocumentTitle: doc.title,
      );
      wordsCollected$.add(wordsCollected$.value + 1);
      highlightWord(null); // Clear highlight after saving
    } catch (_) {
      // Ignore — best-effort vocabulary save
    }
  }

  Future<void> onComplete() async {
    await saveSession();
  }

  // ── Streak logic ──────────────────────────────────────────────────────────

  /// Starts a 1-second tick that accumulates active-reading time and records
  /// the day's streak once cumulative time reaches [_streakThreshold]. The
  /// timer is harmless to call repeatedly — it short-circuits if the streak
  /// has already been recorded this session.
  void _startStreakThresholdTimer() {
    if (_streakRecordedThisSession || _streakThresholdTimer != null) return;
    _streakThresholdTimer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) async {
      if (!_engine.state$.value.isPlaying) return;
      _activeReadingTime += const Duration(seconds: 1);
      if (_activeReadingTime >= _streakThreshold) {
        _streakThresholdTimer?.cancel();
        _streakThresholdTimer = null;
        _streakRecordedThisSession = true;
        await _checkAndIncrementStreak();
      }
    });
  }

  Future<void> _checkAndIncrementStreak() async {
    try {
      await _streakService.recordReading();
      streak$.add(_streakService.streak$.value);
    } catch (_) {
      // Best-effort streak check
    }
  }

  // ── Auto-save & idle detection ─────────────────────────────────────────────

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      _autoSavePartialSession();
    });
  }

  void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    // Only set idle timer for manual mode (not auto-play)
    final isAutoPlaying = _engine.state$.value.isPlaying;
    if (!isAutoPlaying) {
      _idleTimer = Timer(_idleTimeout, _onIdleTimeout);
    }
  }

  void _onIdleTimeout() {
    if (_engine.state$.value.isPlaying) return;
    // Pause session tracking after 60s of inactivity in manual mode
    _autoSavePartialSession();
  }

  Future<void> _autoSavePartialSession() async {
    final doc = document$.valueOrNull;
    if (_isClosed || doc == null || _session == null || sessionSaved$.value) {
      return;
    }

    final now = DateTime.now();

    // Check midnight boundary
    if (_sessionStartTime != null) {
      final startDay = DateTime(
        _sessionStartTime!.year,
        _sessionStartTime!.month,
        _sessionStartTime!.day,
      );
      final nowDay = DateTime(now.year, now.month, now.day);

      if (nowDay.isAfter(startDay)) {
        // Session spans midnight — split it
        await _splitSessionAtMidnight(doc, startDay, now);
        return;
      }
    }

    // Normal partial save — update document progress
    try {
      await _docRepo.updateProgress(
        doc.id,
        doc.currentPage,
        _progressIndex,
      );
    } catch (_) {
      // Best-effort auto-save
    }
  }

  Future<void> _splitSessionAtMidnight(
    DocumentModel doc,
    DateTime startDay,
    DateTime now,
  ) async {
    if (_session == null || _sessionStartTime == null) return;

    final midnight = startDay.add(const Duration(days: 1));
    final totalDurationMs = now.difference(_sessionStartTime!).inMilliseconds;
    final preMidnightMs = midnight
        .difference(_sessionStartTime!)
        .inMilliseconds;
    final wordsReadTotal = _engine.currentWordIndex - _startWordIndex;

    if (totalDurationMs <= 0) return;

    final preMidnightRatio = preMidnightMs / totalDurationMs;
    final preMidnightWords = (wordsReadTotal * preMidnightRatio).round();
    final preMidnightMinutes = preMidnightMs / 60000.0;
    final postMidnightMinutes = (totalDurationMs - preMidnightMs) / 60000.0;
    final postMidnightWords = wordsReadTotal - preMidnightWords;

    final avgWpm = preMidnightMinutes > 0
        ? (preMidnightWords / preMidnightMinutes).round()
        : _engine.currentWpm;

    // Save pre-midnight session
    final preMidnightSession = _session!.copyWith(
      endedAt: midnight,
      durationMinutes: preMidnightMinutes,
      wordsRead: preMidnightWords.clamp(0, _engine.totalWords),
      averageWpm: avgWpm,
    );

    try {
      await _sessionRepo.save(preMidnightSession);
    } catch (_) {}

    // Create new session for post-midnight
    final postAvgWpm = postMidnightMinutes > 0
        ? (postMidnightWords / postMidnightMinutes).round()
        : _engine.currentWpm;

    _sessionStartTime = midnight;
    _startWordIndex = _engine.currentWordIndex - postMidnightWords;
    _session = ReadingSessionModel(
      id: _uuid.v4(),
      documentId: doc.id,
      documentTitle: doc.title,
      startedAt: midnight,
      durationMinutes: postMidnightMinutes,
      wordsRead: postMidnightWords.clamp(0, _engine.totalWords),
      averageWpm: postAvgWpm,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _performanceLabel(int wpm, String complexityLevel) {
    // Thresholds relative to complexity
    final base = switch (complexityLevel) {
      'beginner' => 100,
      'intermediate' => 200,
      'advanced' => 300,
      'expert' => 400,
      _ => 200,
    };
    if (wpm >= base * 1.4) return 'exceptional';
    if (wpm >= base * 0.8) return 'steady';
    return 'warming up';
  }

  ReadingSessionModel? get completedSession =>
      sessionSaved$.value ? _session : null;

  void dispose() {
    _isClosed = true;
    _autoSaveTimer?.cancel();
    _idleTimer?.cancel();
    _backgroundTimer?.cancel();
    _streakThresholdTimer?.cancel();
    _engine.stop();
    document$.close();
    isLoading$.close();
    streak$.close();
    wordsCollected$.close();
    sessionSaved$.close();
    error$.close();
    preferences$.close();
  }
}

// Fallback sample text when document has no extracted text
const _sampleText = '''
The morning mist hung heavy over the harbor, a thick grey veil that seemed to
swallow the very screams of the gulls. I stepped onto the rotting pier, the wood
groaning beneath my weight like a living thing in pain. Everything about the town
felt wrong. The windows of the houses were like sunken eyes, staring blindly into
the void. I felt the gaze of something hidden behind the peeling paint and
salt-crusted glass of the ancient tenements. I moved toward the square, my boots
clicking rhythmically against the uneven cobblestones. There was no one in sight,
yet the air was thick with the smell of dead fish and something older, something
that spoke of deep trenches and forgotten gods. A door creaked open somewhere to
my left. I froze, my breath catching in my throat. The darkness within that doorway
was absolute, a pocket of midnight preserved even in the dull grey light of the
morning.
''';
