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
import 'package:read_it/data/models/pdf_document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/data/models/user_preferences_model.dart';

class ReadingViewModel {
  static const _uuid = Uuid();

  final String documentId;

  final DocumentRepository _docRepo;
  final PreferencesRepository _prefsRepo;
  final SessionRepository _sessionRepo;
  final StreakService _streakService;
  final ReadingEngineService _engine;
  final VocabularyService _vocabService;

  final BehaviorSubject<PdfDocumentModel?> document$ = BehaviorSubject.seeded(
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

  ReadingViewModel({
    required this.documentId,
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

      final doc = results[0] as PdfDocumentModel?;
      final prefs = results[1] as UserPreferencesModel;

      if (doc == null) {
        error$.add(AppStrings.errorDocumentNotFound.tr);
        return;
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
    } else {
      _ensureSessionStarted();
      _engine.play();
    }
  }

  void adjustSpeed(int wpm) {
    _engine.setSpeed(wpm);
  }

  void jumpToWord(int index) {
    _engine.jumpToWord(index);
  }

  void highlightWord(String? word) {
    _engine.highlightWord(word);
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
    _engine.stop();

    final doc = document$.valueOrNull;
    if (_isClosed || doc == null || _session == null || sessionSaved$.value) {
      return;
    }

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
      await _streakService.recordReading();
      streak$.add(_streakService.streak$.value);

      // Update document progress
      await _docRepo.updateProgress(
        doc.id,
        doc.currentPage,
        _engine.currentWordIndex,
      );

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
