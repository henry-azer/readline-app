import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/contracts/session_repository.dart';
import 'package:read_it/data/contracts/vocabulary_repository.dart';
import 'package:read_it/data/enums/app_enums.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/vocabulary_word_model.dart';

/// Combined state for the library body to avoid nested StreamBuilders.
typedef LibraryBodyState = ({
  List<DocumentModel> docs,
  String filter,
  ViewMode viewMode,
  Set<String> selectedIds,
  bool isMultiSelect,
  String sortField,
  bool sortAsc,
});

class LibraryViewModel {
  final DocumentRepository _docRepo;
  final PreferencesRepository _prefsRepo;
  final SessionRepository _sessionRepo;
  final VocabularyRepository _vocabRepo;
  final PdfProcessingService _pdfService;

  final BehaviorSubject<List<DocumentModel>> allDocuments$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<List<DocumentModel>> documents$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<String> activeFilter$ = BehaviorSubject.seeded('all');
  final BehaviorSubject<ViewMode> viewMode$ = BehaviorSubject.seeded(
    ViewMode.grid,
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> importError$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<String> searchQuery$ = BehaviorSubject.seeded('');
  final BehaviorSubject<String> sortField$ = BehaviorSubject.seeded('lastRead');
  final BehaviorSubject<bool> sortAscending$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<Set<String>> selectedIds$ = BehaviorSubject.seeded(
    const {},
  );
  final BehaviorSubject<bool> isMultiSelectMode$ = BehaviorSubject.seeded(
    false,
  );

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

  /// Combined stream for the library body UI — replaces nested StreamBuilders.
  late final Stream<LibraryBodyState> bodyState$ = Rx.combineLatest7(
    documents$,
    activeFilter$,
    viewMode$,
    selectedIds$,
    isMultiSelectMode$,
    sortField$,
    sortAscending$,
    (
      docs,
      filter,
      viewMode,
      selectedIds,
      isMultiSelect,
      sortField,
      sortAsc,
    ) => (
      docs: docs,
      filter: filter,
      viewMode: viewMode,
      selectedIds: selectedIds,
      isMultiSelect: isMultiSelect,
      sortField: sortField,
      sortAsc: sortAsc,
    ),
  );

  LibraryViewModel({
    DocumentRepository? docRepo,
    PreferencesRepository? prefsRepo,
    SessionRepository? sessionRepo,
    VocabularyRepository? vocabRepo,
    PdfProcessingService? pdfService,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _sessionRepo = sessionRepo ?? getIt<SessionRepository>(),
       _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>(),
       _pdfService = pdfService ?? getIt<PdfProcessingService>();

  String get currentFilter => activeFilter$.value;
  ViewMode get currentViewMode => viewMode$.value;
  int get documentCount => allDocuments$.value.length;
  bool get isMultiSelectActive => isMultiSelectMode$.value;

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
    final prefs = await _prefsRepo.get();
    sortField$.add(prefs.librarySortField);
    sortAscending$.add(prefs.librarySortAscending);
    await refresh();
  }

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      final docs = await _docRepo.getAll();
      allDocuments$.add(docs);
      _applyAllFilters();
    } finally {
      isLoading$.add(false);
    }
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

  // ── Sorting ───────────────────────────────────────────────────────────────

  void setSortField(String field) {
    sortField$.add(field);
    _applyAllFilters();
    _persistSortPreferences();
  }

  void toggleSortDirection() {
    sortAscending$.add(!sortAscending$.value);
    _applyAllFilters();
    _persistSortPreferences();
  }

  Future<void> _persistSortPreferences() async {
    try {
      final prefs = await _prefsRepo.get();
      await _prefsRepo.save(
        prefs.copyWith(
          librarySortField: sortField$.value,
          librarySortAscending: sortAscending$.value,
        ),
      );
    } catch (_) {}
  }

  // ── Multi-select ──────────────────────────────────────────────────────────

  void toggleMultiSelect() {
    final isActive = !isMultiSelectMode$.value;
    isMultiSelectMode$.add(isActive);
    if (!isActive) {
      selectedIds$.add(const {});
    }
  }

  void exitMultiSelect() {
    isMultiSelectMode$.add(false);
    selectedIds$.add(const {});
  }

  void toggleSelection(String docId) {
    final current = Set<String>.from(selectedIds$.value);
    if (current.contains(docId)) {
      current.remove(docId);
    } else {
      current.add(docId);
    }
    selectedIds$.add(current);
  }

  void activateMultiSelectWith(String docId) {
    isMultiSelectMode$.add(true);
    selectedIds$.add({docId});
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

    final updated = [...allDocuments$.value, document];
    allDocuments$.add(updated);
    _applyAllFilters();
  }

  Future<void> deleteSelectedDocuments() async {
    final ids = Set<String>.from(selectedIds$.value);
    for (final id in ids) {
      await deleteDocument(id);
    }
    exitMultiSelect();
  }

  Future<bool> importDocument() async {
    importError$.add(null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return false;
      final path = result.files.single.path;
      if (path == null) return false;

      final doc = await _pdfService.processFile(File(path));
      await _docRepo.save(doc);
      await refresh();
      return true;
    } catch (_) {
      importError$.add(AppStrings.errorImportPdf.tr);
      return false;
    }
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

    // Search query
    final query = searchQuery$.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.title.toLowerCase().contains(query) ||
            (d.description?.toLowerCase().contains(query) ?? false) ||
            d.extractedText.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    _sortDocuments(filtered);

    documents$.add(filtered);
  }

  void _sortDocuments(List<DocumentModel> docs) {
    final field = sortField$.value;
    final asc = sortAscending$.value;

    docs.sort((a, b) {
      int cmp;
      switch (field) {
        case 'lastRead':
          final aDate = a.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          cmp = aDate.compareTo(bDate);
        case 'dateAdded':
          cmp = a.importedAt.compareTo(b.importedAt);
        case 'title':
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'progress':
          final aProg = a.totalWords > 0 ? a.wordsRead / a.totalWords : 0.0;
          final bProg = b.totalWords > 0 ? b.wordsRead / b.totalWords : 0.0;
          cmp = aProg.compareTo(bProg);
        case 'wordCount':
          cmp = a.totalWords.compareTo(b.totalWords);
        default:
          cmp = 0;
      }
      return asc ? cmp : -cmp;
    });
  }

  void dispose() {
    _searchDebounce?.cancel();
    allDocuments$.close();
    documents$.close();
    activeFilter$.close();
    viewMode$.close();
    isLoading$.close();
    importError$.close();
    searchQuery$.close();
    sortField$.close();
    sortAscending$.close();
    selectedIds$.close();
    isMultiSelectMode$.close();
    filterStatuses$.close();
    filterSourceTypes$.close();
    filterDateRange$.close();
  }
}
