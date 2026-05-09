import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:readline_app/app.dart'
    show sessionChangeNotifier, vocabChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/celebration_service.dart';
import 'package:readline_app/core/services/reading_engine_service.dart';
import 'package:readline_app/core/services/streak_service.dart';
import 'package:readline_app/core/services/vocabulary_service.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/entities/reading_state.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

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
  final CelebrationService _celebrationService;

  final BehaviorSubject<DocumentModel?> document$ = BehaviorSubject.seeded(
    null,
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(true);
  final BehaviorSubject<int> wordsCollected$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<bool> sessionSaved$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> error$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<UserPreferencesModel?> preferences$ =
      BehaviorSubject.seeded(null);

  // Direct access to engine state for StreamBuilder
  Stream<ReadingState> get readingState$ => _engine.state$.stream;

  /// The reading engine instance — exposed for `ReadingDisplay` which renders
  /// per-word state and needs direct access (highlight, focus text, etc.).
  ReadingEngineService get engine => _engine;

  /// Synchronous snapshot of the engine's current state — used as the
  /// `initialData` for `StreamBuilder<ReadingState>` so the first frame
  /// doesn't flash empty.
  ReadingState get currentReadingState => _engine.state$.value;

  /// Current target WPM — used by speed +/- callbacks to compute the next
  /// preset value before clamping.
  int get currentWpm => _engine.currentWpm;

  /// Total word count — used by the seek slider to convert progress (0..1)
  /// into a target word index.
  int get totalWords => _engine.totalWords;

  /// Pending celebration stream (proxied from `CelebrationService`) — the
  /// screen subscribes to push milestone overlays on top of the reader.
  Stream<CelebrationData?> get pendingCelebration$ =>
      _celebrationService.pendingCelebration$;

  /// Begins listening for celebration triggers. Idempotent.
  Future<void> startCelebrationListening() =>
      _celebrationService.startListening();

  /// Clears the currently-pending celebration after the user dismisses it.
  void clearPendingCelebration() => _celebrationService.clearPending();

  /// Whether [word] is already saved in the user's vocabulary.
  Future<bool> isWordSaved(String word) => _vocabService.isWordSaved(word);

  ReadingSessionModel? _session;
  DateTime? _sessionStartTime;
  int _startWordIndex = 0;
  bool _isClosed = false;
  Timer? _autoSaveTimer;
  Timer? _idleTimer;
  Timer? _backgroundTimer;
  Timer? _streakCheckTimer;
  // Active-time tracking: timestamp the engine started its current play
  // period, plus a running accumulator of fully-finished play periods.
  // Together they give millisecond-accurate active reading time, used by
  // the session summary's avg-WPM and focus-score calculations.
  DateTime? _activePlayStartedAt;
  Duration _accumulatedActiveTime = Duration.zero;
  // Sum of (configured WPM × ms spent at that WPM) across all play
  // periods. Divided by total active ms at session end to get the
  // time-weighted avg WPM — what the user's speed dial actually was while
  // they were reading, regardless of the smooth-scroll heuristic's
  // imperfect words-per-line estimate.
  int _wpmActiveMsSum = 0;
  int _wpmAtPlayStart = 0;
  StreamSubscription<bool>? _playingSub;
  // Words *actually* read in this session — counts only sequential forward
  // advances of the engine's word index. Explicit jumps (slider seeks)
  // and resume-from-position emissions are excluded so they don't inflate
  // the avg-WPM calculation.
  int _actualWordsRead = 0;
  int _lastSeenWordIndex = 0;
  bool _countingActiveWords = false;
  bool _ignoreNextWordDelta = false;
  StreamSubscription<int>? _wordIndexSub;
  bool _streakRecordedThisSession = false;
  DateTime? _pausedAt;
  bool _wasPlayingBeforePause = false;
  // Time the user spent in modal UI while a session was active — word-
  // lookup popups, the player-settings sheet, etc. Subtracted from total
  // session time when computing the focus score so adjusting speed,
  // changing font, or looking up a vocab word isn't punished as
  // "lost focus".
  Duration _interactivePauseTime = Duration.zero;
  DateTime? _interactivePauseStartedAt;

  ReadingViewModel({
    required this.documentId,
    this.restart = false,
    DocumentRepository? docRepo,
    PreferencesRepository? prefsRepo,
    SessionRepository? sessionRepo,
    StreakService? streakService,
    ReadingEngineService? engine,
    VocabularyService? vocabService,
    CelebrationService? celebrationService,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _streakService = streakService ?? getIt<StreakService>(),
       _engine = engine ?? getIt<ReadingEngineService>(),
       _vocabService = vocabService ?? getIt<VocabularyService>(),
       _celebrationService =
           celebrationService ?? getIt<CelebrationService>() {
    // Track engine play/pause transitions to keep active reading time
    // accurate to the millisecond.
    _playingSub = _engine.state$.stream
        .map((s) => s.isPlaying)
        .distinct()
        .listen(_onEnginePlayingChanged);
    // Track word-index advances to count *actual* reading. Slider seeks
    // mark `_ignoreNextWordDelta = true` before calling jumpToWord so the
    // jump doesn't count as words read.
    _wordIndexSub = _engine.state$.stream
        .map((s) => s.currentWordIndex)
        .distinct()
        .listen(_onEngineWordIndexChanged);
  }

  void _onEngineWordIndexChanged(int currentIndex) {
    final delta = currentIndex - _lastSeenWordIndex;
    _lastSeenWordIndex = currentIndex;
    if (!_countingActiveWords) return;
    if (_ignoreNextWordDelta) {
      _ignoreNextWordDelta = false;
      return;
    }
    if (delta > 0) {
      _actualWordsRead += delta;
    }
    // Backward / zero deltas are silently ignored (re-emissions, seeks
    // backward, etc.).
  }

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
      // Also auto-restart when the document is already completed —
      // `isCompleted` covers both the explicit `'completed'` status and
      // the engine's `wordsRead >= totalWords - 1` plateau, so this
      // self-heals docs left one word short of the end by an older
      // engine build that would otherwise reopen into a frozen player.
      final shouldRestart = restart || doc.isCompleted;
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
      _ensureStreakCheckTimer();
      _resetIdleTimer();
    }
  }

  /// Fires once a second while play is active (and stops itself once the
  /// streak has been recorded) — so a continuous read crosses the streak
  /// threshold without needing a pause to flush the active-time accumulator.
  void _ensureStreakCheckTimer() {
    if (_streakRecordedThisSession || _streakCheckTimer != null) return;
    _streakCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_streakRecordedThisSession) {
        _streakCheckTimer?.cancel();
        _streakCheckTimer = null;
        return;
      }
      if (_totalActiveTime >= _streakThreshold) {
        _streakRecordedThisSession = true;
        _streakCheckTimer?.cancel();
        _streakCheckTimer = null;
        await _checkAndIncrementStreak();
      }
    });
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
    // Same actual-words-read accounting as the normal save path.
    final wordsRead = _actualWordsRead.clamp(0, _engine.totalWords);
    final endTime = _pausedAt ?? now;
    final durationMs = endTime.difference(_sessionStartTime!).inMilliseconds;
    _flushActivePlayPeriod();
    final activeMs = _totalActiveTime.inMilliseconds > 0
        ? _totalActiveTime.inMilliseconds
        : durationMs;
    final activeMinutes = activeMs / 60000.0;
    final avgWpm = _wpmActiveMsSum > 0 && activeMs > 0
        ? (_wpmActiveMsSum / activeMs).round()
        : (activeMinutes > 0
            ? (wordsRead / activeMinutes).round()
            : _engine.currentWpm);
    endInteractivePause();
    final focusDenominatorMs =
        (durationMs - _interactivePauseTime.inMilliseconds).clamp(activeMs, durationMs);
    final focusScore = focusDenominatorMs > 0
        ? (activeMs / focusDenominatorMs * 100).clamp(0.0, 100.0)
        : 100.0;

    final finalSession = _session!.copyWith(
      endedAt: endTime,
      durationMinutes: activeMinutes,
      wordsRead: wordsRead,
      averageWpm: avgWpm,
      endPage: doc.currentPage,
      focusScore: focusScore,
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
    _accumulatedActiveTime = Duration.zero;
    _activePlayStartedAt = null;
    _wpmActiveMsSum = 0;
    _wpmAtPlayStart = 0;
    _actualWordsRead = 0;
    _countingActiveWords = false;
    _interactivePauseTime = Duration.zero;
    _interactivePauseStartedAt = null;
    sessionSaved$.add(false);
    _wasPlayingBeforePause = false;
  }

  void adjustSpeed(int wpm) {
    // Flush the open play period at the OLD WPM before the engine swaps
    // its internal _wpm — otherwise the elapsed time at the old speed
    // would be credited to the new speed in the time-weighted average.
    // The engine's setSpeed() will fire pause+play state changes which
    // re-arm `_activePlayStartedAt` (and `_wpmAtPlayStart`) at the new
    // value via `_onEnginePlayingChanged`.
    _flushActivePlayPeriod();
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
    // Mark the upcoming state emission as a jump so the word-index
    // listener doesn't credit the user with reading the words skipped.
    _ignoreNextWordDelta = true;
    _engine.jumpToWord(index);
  }

  /// Called when the user enters a modal flow that pauses reading
  /// (word-definition popup, player-settings sheet, …). The time between
  /// this call and [endInteractivePause] is excluded from the focus
  /// score's denominator so adjusting speed or looking up a word doesn't
  /// drag focus down.
  void beginInteractivePause() {
    _interactivePauseStartedAt ??= DateTime.now();
  }

  /// Pairs with [beginInteractivePause] — call when the modal closes.
  void endInteractivePause() {
    final start = _interactivePauseStartedAt;
    if (start == null) return;
    _interactivePauseTime += DateTime.now().difference(start);
    _interactivePauseStartedAt = null;
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
    // Begin counting words read from the current engine position. Any
    // jumps that happened before this point (e.g., resume-from-position
    // during init) are excluded.
    _lastSeenWordIndex = _engine.currentWordIndex;
    _actualWordsRead = 0;
    _ignoreNextWordDelta = false;
    _countingActiveWords = true;
  }

  Future<void> saveSession() async {
    final doc = document$.valueOrNull;
    if (_isClosed || doc == null || _session == null || sessionSaved$.value) {
      _engine.stop();
      return;
    }
    _engine.stop();

    final now = DateTime.now();
    // wordsRead = words *actually advanced through* during this session
    // (excludes anything skipped via slider seeks). For a fully auto-
    // played complete read this equals totalWords; for a slider-jump-to-
    // end it's whatever was read before the jump.
    final isComplete = _engine.state$.value.isComplete;
    final wordsRead = (isComplete &&
                _actualWordsRead >= _engine.totalWords - 1
            ? _engine.totalWords
            : _actualWordsRead)
        .clamp(0, _engine.totalWords);
    final durationMs = now.difference(_sessionStartTime!).inMilliseconds;
    // Flush any in-progress play period so _totalActiveTime is final.
    _flushActivePlayPeriod();
    // Active reading time only — excludes paused / idle periods. Falls back
    // to total session time on rare manual-only sessions where the engine
    // never reported a play state.
    final activeMs = _totalActiveTime.inMilliseconds > 0
        ? _totalActiveTime.inMilliseconds
        : durationMs;
    final activeMinutes = activeMs / 60000.0;
    // Time-weighted average of the configured WPM during active play —
    // matches what the user dialed-in regardless of how the smooth-scroll
    // heuristic translated that into pixels-per-second. Falls back to the
    // measured `wordsRead / activeMinutes` rate if no WPM time was ever
    // captured (manual-only session with no auto-play).
    final avgWpm = _wpmActiveMsSum > 0 && activeMs > 0
        ? (_wpmActiveMsSum / activeMs).round()
        : (activeMinutes > 0
            ? (wordsRead / activeMinutes).round()
            : _engine.currentWpm);
    // Focus = ratio of active reading time to total session time, in
    // percent. A session with no pauses scores 100; long pauses drag the
    // score down proportionally. Interactive pauses (word lookup, player
    // settings, …) are excluded so adjusting speed/font or looking up a
    // vocab word doesn't punish focus.
    endInteractivePause();
    final focusDenominatorMs =
        (durationMs - _interactivePauseTime.inMilliseconds).clamp(activeMs, durationMs);
    final focusScore = focusDenominatorMs > 0
        ? (activeMs / focusDenominatorMs * 100).clamp(0.0, 100.0)
        : 100.0;
    final perfLabel = _performanceLabel(avgWpm, doc.complexityLevel);

    final finalSession = _session!.copyWith(
      endedAt: now,
      durationMinutes: activeMinutes,
      wordsRead: wordsRead,
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

      // Notify any analytics-facing screens to recompute.
      sessionChangeNotifier.value++;

      // Trigger end-of-session celebration checks (daily target + cumulative
      // word milestone). Streak-milestone celebrations are already pushed by
      // CelebrationService's listener when the streak increments above.
      await _runPostSessionCelebrationChecks();
    } catch (_) {
      // Best-effort save — do not surface error on exit
    }
  }

  Future<void> _runPostSessionCelebrationChecks() async {
    try {
      await _celebrationService.checkDailyTarget();
      final docs = await _docRepo.getAll();
      final totalWordsRead =
          docs.fold<int>(0, (sum, d) => sum + d.wordsRead);
      await _celebrationService.checkWordsMilestone(totalWordsRead);
    } catch (_) {
      // Best-effort — celebrations are non-critical
    }
  }

  Future<void> removeWordFromVocabulary(String word) async {
    try {
      await _vocabService.removeSavedWord(word);
      if (wordsCollected$.value > 0) {
        wordsCollected$.add(wordsCollected$.value - 1);
      }
      sessionChangeNotifier.value++;
      vocabChangeNotifier.value++;
    } catch (_) {
      // Best-effort
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
      sessionChangeNotifier.value++;
      vocabChangeNotifier.value++;
    } catch (_) {
      // Ignore — best-effort vocabulary save
    }
  }

  Future<void> onComplete() async {
    await saveSession();
  }

  // ── Streak logic ──────────────────────────────────────────────────────────

  /// Called when the engine transitions between playing and paused. Tracks
  /// active reading time accurately (timestamp deltas, not 1-second ticks)
  /// and triggers the daily-streak record once cumulative active time
  /// crosses [_streakThreshold].
  void _onEnginePlayingChanged(bool isPlaying) {
    if (isPlaying) {
      if (_activePlayStartedAt == null) {
        _activePlayStartedAt = DateTime.now();
        _wpmAtPlayStart = _engine.currentWpm;
      }
    } else {
      _flushActivePlayPeriod();
      if (!_streakRecordedThisSession &&
          _accumulatedActiveTime >= _streakThreshold) {
        _streakRecordedThisSession = true;
        unawaited(_checkAndIncrementStreak());
      }
    }
  }

  /// Closes any open play period: adds (now - startedAt) to the active-
  /// time accumulator AND adds (wpmAtStart × elapsed-ms) to the WPM
  /// time-weighted accumulator. Idempotent.
  void _flushActivePlayPeriod() {
    final start = _activePlayStartedAt;
    if (start == null) return;
    final elapsed = DateTime.now().difference(start);
    _accumulatedActiveTime += elapsed;
    _wpmActiveMsSum += elapsed.inMilliseconds * _wpmAtPlayStart;
    _activePlayStartedAt = null;
  }

  /// Total active reading time for this session, including any in-progress
  /// play period.
  Duration get _totalActiveTime {
    final accumulated = _accumulatedActiveTime;
    final start = _activePlayStartedAt;
    if (start == null) return accumulated;
    return accumulated + DateTime.now().difference(start);
  }

  Future<void> _checkAndIncrementStreak() async {
    try {
      await _streakService.recordReading();
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
      sessionChangeNotifier.value++;
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
    _streakCheckTimer?.cancel();
    _playingSub?.cancel();
    _wordIndexSub?.cancel();
    _engine.stop();
    document$.close();
    isLoading$.close();
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
