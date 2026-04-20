import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/services/streak_service.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/contracts/session_repository.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/models/pdf_document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/data/models/user_preferences_model.dart';

class HomeStats {
  final int totalDocs;
  final int avgSpeedWpm;
  final int totalWordsRead;

  const HomeStats({
    this.totalDocs = 0,
    this.avgSpeedWpm = 0,
    this.totalWordsRead = 0,
  });
}

class HomeViewModel {
  final DocumentRepository _docRepo;
  final SessionRepository _sessionRepo;
  final PreferencesRepository _prefsRepo;
  final StreakService _streakService;

  final BehaviorSubject<List<PdfDocumentModel>> documents$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<PdfDocumentModel?> currentDocument$ =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<List<ReadingSessionModel>> recentSessions$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<StreakModel> streak$ = BehaviorSubject.seeded(
    const StreakModel(),
  );
  final BehaviorSubject<HomeStats> stats$ = BehaviorSubject.seeded(
    const HomeStats(),
  );
  final BehaviorSubject<UserPreferencesModel?> preferences$ =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);

  HomeViewModel({
    DocumentRepository? docRepo,
    SessionRepository? sessionRepo,
    PreferencesRepository? prefsRepo,
    StreakService? streakService,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _streakService = streakService ?? getIt<StreakService>();

  bool get isEmpty => documents$.value.isEmpty;

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      await _streakService.refresh();
      final results = await Future.wait([
        _docRepo.getAll(),
        _sessionRepo.getRecent(5),
        _prefsRepo.get(),
      ]);

      final docs = results[0] as List<PdfDocumentModel>;
      final sessions = results[1] as List<ReadingSessionModel>;
      final prefs = results[2] as UserPreferencesModel;

      documents$.add(docs);
      recentSessions$.add(sessions);
      preferences$.add(prefs);
      streak$.add(_streakService.streak$.value);

      // Resolve current document: last-read or most recently imported
      PdfDocumentModel? current;
      if (docs.isNotEmpty) {
        final sorted = [...docs]
          ..sort((a, b) {
            final aDate = a.lastReadAt ?? a.importedAt;
            final bDate = b.lastReadAt ?? b.importedAt;
            return bDate.compareTo(aDate);
          });
        current = sorted.first;
      }
      currentDocument$.add(current);

      // Compute stats
      final totalWordsRead = docs.fold<int>(0, (sum, d) => sum + d.wordsRead);
      final avgWpm = sessions.isEmpty
          ? prefs.readingSpeedWpm
          : (sessions.fold<int>(0, (s, r) => s + r.averageWpm) ~/
                sessions.length);

      stats$.add(
        HomeStats(
          totalDocs: docs.length,
          avgSpeedWpm: avgWpm,
          totalWordsRead: totalWordsRead,
        ),
      );
    } finally {
      isLoading$.add(false);
    }
  }

  void dispose() {
    documents$.close();
    currentDocument$.close();
    recentSessions$.close();
    streak$.close();
    stats$.close();
    preferences$.close();
    isLoading$.close();
  }
}
