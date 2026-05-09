import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/enums/view_mode.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/data/models/reading_session_model.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/data/utils/document_sort.dart';

/// Combined state for the library body to avoid nested StreamBuilders.
typedef LibraryBodyState = ({
  List<DocumentModel> docs,
  String filter,
  ViewMode viewMode,
});

class LibraryViewModel {
  final DocumentRepository _docRepo;
  final PreferencesRepository _prefsRepo;
  final SessionRepository _sessionRepo;
  final VocabularyRepository _vocabRepo;

  final BehaviorSubject<List<DocumentModel>> allDocuments$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<List<DocumentModel>> documents$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<String> activeFilter$ = BehaviorSubject.seeded('all');
  final BehaviorSubject<ViewMode> viewMode$ = BehaviorSubject.seeded(
    ViewMode.grid,
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> searchQuery$ = BehaviorSubject.seeded('');

  // Advanced filters
  final BehaviorSubject<Set<String>> filterStatuses$ = BehaviorSubject.seeded(
    const {},
  );
  final BehaviorSubject<Set<String>> filterSourceTypes$ =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<String?> filterDateRange$ = BehaviorSubject.seeded(
    null,
  );

  Timer? _searchDebounce;

  /// Reactive count of active advanced filters — drives the app-bar badge.
  late final Stream<int> activeFilterCount$ = Rx.combineLatest3(
    filterStatuses$,
    filterSourceTypes$,
    filterDateRange$,
    (Set<String> statuses, Set<String> sources, String? range) {
      var count = 0;
      if (statuses.isNotEmpty) count++;
      if (sources.isNotEmpty) count++;
      if (range != null) count++;
      return count;
    },
  );

  /// Combined stream for the library body UI — replaces nested StreamBuilders.
  late final Stream<LibraryBodyState> bodyState$ = Rx.combineLatest3(
    documents$,
    activeFilter$,
    viewMode$,
    (List<DocumentModel> docs, String filter, ViewMode viewMode) => (
      docs: docs,
      filter: filter,
      viewMode: viewMode,
    ),
  );

  LibraryViewModel({
    DocumentRepository? docRepo,
    PreferencesRepository? prefsRepo,
    SessionRepository? sessionRepo,
    VocabularyRepository? vocabRepo,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>();

  /// Cached preferred reading speed — used by tiles to estimate minutes left
  /// vs. minutes total. Resolved from user prefs in [init]; falls back to the
  /// model default (200 WPM) until prefs load.
  int currentWpm = 200;

  /// Sum of session `durationMinutes` per document id. Tiles use this for
  /// completed documents so the time label reflects what the user actually
  /// spent rather than a projected total. Refreshed from the session repo
  /// on every [refresh] call.
  Map<String, double> _actualMinutesByDoc = const {};

  double? actualMinutesFor(String docId) => _actualMinutesByDoc[docId];

  String get currentFilter => activeFilter$.value;
  ViewMode get currentViewMode => viewMode$.value;
  int get documentCount => allDocuments$.value.length;

  Map<String, int> get filterCounts {
    final all = allDocuments$.value;
    return {
      'all': all.length,
      'reading': all.where((d) => d.isInProgress).length,
      'completed': all.where((d) => d.isCompleted).length,
      'unread': all.where((d) => d.isUnread).length,
    };
  }

  int get activeFilterCount {
    int count = 0;
    if (filterStatuses$.value.isNotEmpty) count++;
    if (filterSourceTypes$.value.isNotEmpty) count++;
    if (filterDateRange$.value != null) count++;
    return count;
  }

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      final results = await Future.wait([
        _docRepo.getAll(),
        _prefsRepo.get(),
        _sessionRepo.getAll(),
      ]);
      final docs = results[0] as List<DocumentModel>;
      final prefs = results[1] as UserPreferencesModel;
      final sessions = results[2] as List<ReadingSessionModel>;
      currentWpm = prefs.readingSpeedWpm;
      _actualMinutesByDoc = _aggregateDurations(sessions);
      allDocuments$.add(docs);
      _applyAllFilters();
    } finally {
      isLoading$.add(false);
    }
  }

  Map<String, double> _aggregateDurations(List<ReadingSessionModel> sessions) {
    final result = <String, double>{};
    for (final s in sessions) {
      result.update(
        s.documentId,
        (prev) => prev + s.durationMinutes,
        ifAbsent: () => s.durationMinutes,
      );
    }
    return result;
  }

  // ── Quick filter chips ──────────────────────────────────────────────────────

  void setFilter(String filter) {
    activeFilter$.add(filter);
    _applyAllFilters();
  }

  void toggleViewMode() {
    final next = viewMode$.value == ViewMode.grid
        ? ViewMode.list
        : ViewMode.grid;
    viewMode$.add(next);
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(AppDurations.debounce, () {
      searchQuery$.add(query);
      _applyAllFilters();
    });
  }

  void clearSearch() {
    searchQuery$.add('');
    _applyAllFilters();
  }

  // ── Advanced filters ──────────────────────────────────────────────────────

  void setFilterStatuses(Set<String> statuses) {
    filterStatuses$.add(statuses);
    _applyAllFilters();
  }

  void setFilterSourceTypes(Set<String> types) {
    filterSourceTypes$.add(types);
    _applyAllFilters();
  }

  void setFilterDateRange(String? range) {
    filterDateRange$.add(range);
    _applyAllFilters();
  }

  void clearAllAdvancedFilters() {
    filterStatuses$.add(const {});
    filterSourceTypes$.add(const {});
    filterDateRange$.add(null);
    _applyAllFilters();
  }

  // ── CRUD: Documents ───────────────────────────────────────────────────────

  /// Captured cascade data for undo support.
  List<ReadingSessionModel>? _deletedSessions;
  List<VocabularyWordModel>? _deletedVocabWords;

  Future<void> deleteDocument(String id) async {
    // Capture cascade data before deletion for undo support
    _deletedSessions = await _sessionRepo.getByDocumentId(id);
    _deletedVocabWords = await _vocabRepo.getByDocumentId(id);

    // Cascade delete: sessions for this document
    await _sessionRepo.deleteByDocumentId(id);
    // Clear source document reference from vocabulary
    await _vocabRepo.clearSourceDocument(id);
    // Delete the document itself
    await _docRepo.delete(id);

    final updated = allDocuments$.value.where((d) => d.id != id).toList();
    allDocuments$.add(updated);
    _applyAllFilters();
  }

  Future<void> undoDelete(DocumentModel document) async {
    await _docRepo.save(document);

    // Restore cascade-deleted sessions
    final sessions = _deletedSessions;
    if (sessions != null) {
      for (final session in sessions) {
        await _sessionRepo.save(session);
      }
    }

    // Restore vocab word source document references
    final vocabWords = _deletedVocabWords;
    if (vocabWords != null) {
      for (final word in vocabWords) {
        await _vocabRepo.save(word);
      }
    }

    _deletedSessions = null;
    _deletedVocabWords = null;

    // Dedupe-then-append so this is idempotent even if a notifier-driven
    // refresh raced with us and already restored the doc via getAll().
    final updated = [
      ...allDocuments$.value.where((d) => d.id != document.id),
      document,
    ];
    allDocuments$.add(updated);
    _applyAllFilters();
  }

  // ── Filter engine ─────────────────────────────────────────────────────────

  void _applyAllFilters() {
    var filtered = List<DocumentModel>.from(allDocuments$.value);

    // Quick filter chips
    final quickFilter = activeFilter$.value;
    filtered = switch (quickFilter) {
      'reading' => filtered.where((d) => d.isInProgress).toList(),
      'completed' => filtered.where((d) => d.isCompleted).toList(),
      'unread' => filtered.where((d) => d.isUnread).toList(),
      _ => filtered,
    };

    // Advanced status filter
    final statuses = filterStatuses$.value;
    if (statuses.isNotEmpty) {
      filtered = filtered
          .where((d) => statuses.contains(d.readingStatus))
          .toList();
    }

    // Source type filter
    final sourceTypes = filterSourceTypes$.value;
    if (sourceTypes.isNotEmpty) {
      filtered = filtered
          .where((d) => sourceTypes.contains(d.sourceType))
          .toList();
    }

    // Date range filter
    final dateRange = filterDateRange$.value;
    if (dateRange != null) {
      final now = DateTime.now();
      final start = switch (dateRange) {
        'today' => DateTime(now.year, now.month, now.day),
        'thisWeek' => DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1)),
        'thisMonth' => DateTime(now.year, now.month, 1),
        _ => null,
      };
      if (start != null) {
        filtered = filtered.where((d) => d.importedAt.isAfter(start)).toList();
      }
    }

    // Search query — match against the document title only.
    final query = searchQuery$.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((d) => d.title.toLowerCase().contains(query))
          .toList();
    }

    // Sort — canonical tri-tier order, the only sort the library offers.
    sortDocumentsSmart(filtered);

    documents$.add(filtered);
  }

  void dispose() {
    _searchDebounce?.cancel();
    allDocuments$.close();
    documents$.close();
    activeFilter$.close();
    viewMode$.close();
    isLoading$.close();
    searchQuery$.close();
    filterStatuses$.close();
    filterSourceTypes$.close();
    filterDateRange$.close();
  }
}
