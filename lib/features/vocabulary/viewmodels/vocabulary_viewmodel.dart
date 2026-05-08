import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/services/vocabulary_service.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';

class VocabularyStats {
  final int total;
  final int mastered;
  final int dueForReview;
  final int learning;
  final int fresh;
  final int easy;
  final int medium;
  final int hard;

  const VocabularyStats({
    this.total = 0,
    this.mastered = 0,
    this.dueForReview = 0,
    this.learning = 0,
    this.fresh = 0,
    this.easy = 0,
    this.medium = 0,
    this.hard = 0,
  });
}

/// Sort options for vocabulary list.
enum VocabSortOption { dateAdded, alphabetical, difficulty }

/// Active filter configuration for advanced filtering.
class VocabFilterConfig {
  final Set<String> difficulties;
  final String? sourceDocument;
  final String? dateRange;

  const VocabFilterConfig({
    this.difficulties = const {},
    this.sourceDocument,
    this.dateRange,
  });

  int get activeCount {
    int count = 0;
    if (difficulties.isNotEmpty) count++;
    if (sourceDocument != null) count++;
    if (dateRange != null && dateRange != 'all') count++;
    return count;
  }

  bool get isEmpty => activeCount == 0;

  VocabFilterConfig copyWith({
    Set<String>? difficulties,
    String? sourceDocument,
    String? dateRange,
    bool clearSource = false,
    bool clearDateRange = false,
  }) {
    return VocabFilterConfig(
      difficulties: difficulties ?? this.difficulties,
      sourceDocument: clearSource
          ? null
          : (sourceDocument ?? this.sourceDocument),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

class VocabularyViewModel {
  final VocabularyRepository _vocabRepo;
  final VocabularyService _vocabService;
  final PreferencesRepository _prefsRepo;

  final BehaviorSubject<List<VocabularyWordModel>> allWords$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<List<VocabularyWordModel>> words$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<String> activeFilter$ = BehaviorSubject.seeded('all');
  final BehaviorSubject<VocabularyStats> stats$ = BehaviorSubject.seeded(
    const VocabularyStats(),
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> searchQuery$ = BehaviorSubject.seeded('');
  final BehaviorSubject<VocabSortOption> sortOption$ = BehaviorSubject.seeded(
    VocabSortOption.dateAdded,
  );
  final BehaviorSubject<bool> sortAscending$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<VocabFilterConfig> filterConfig$ =
      BehaviorSubject.seeded(const VocabFilterConfig());
  final BehaviorSubject<Set<String>> expandedCards$ = BehaviorSubject.seeded(
    const {},
  );

  Timer? _searchDebounce;

  VocabularyViewModel({
    VocabularyRepository? vocabRepo,
    VocabularyService? vocabService,
    PreferencesRepository? prefsRepo,
  }) : _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>(),
       _vocabService = vocabService ?? getIt<VocabularyService>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>();

  String get currentFilter => activeFilter$.value;
  int get wordCount => allWords$.value.length;
  List<VocabularyWordModel> get currentWords => words$.value;

  Future<void> init() async {
    // Load persisted sort preferences
    final prefs = await _prefsRepo.get();
    final sortField = switch (prefs.vocabSortField) {
      'alphabetical' => VocabSortOption.alphabetical,
      'difficulty' => VocabSortOption.difficulty,
      _ => VocabSortOption.dateAdded,
    };
    sortOption$.add(sortField);
    sortAscending$.add(prefs.vocabSortAscending);

    await refresh();
  }

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      final words = await _vocabRepo.getAll();
      allWords$.add(words);
      _refilter();
      _computeStats(words);
    } finally {
      isLoading$.add(false);
    }
  }

  void setFilter(String filter) {
    activeFilter$.add(filter);
    _refilter();
  }

  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(AppDurations.debounce, () {
      searchQuery$.add(query);
      _refilter();
    });
  }

  void setSortOption(VocabSortOption option) {
    sortOption$.add(option);
    _refilter();
    _persistSortPreference();
  }

  void toggleSortDirection() {
    sortAscending$.add(!sortAscending$.value);
    _refilter();
    _persistSortPreference();
  }

  Future<void> _persistSortPreference() async {
    final fieldName = switch (sortOption$.value) {
      VocabSortOption.alphabetical => 'alphabetical',
      VocabSortOption.difficulty => 'difficulty',
      VocabSortOption.dateAdded => 'dateAdded',
    };
    final prefs = await _prefsRepo.get();
    await _prefsRepo.save(
      prefs.copyWith(
        vocabSortField: fieldName,
        vocabSortAscending: sortAscending$.value,
      ),
    );
  }

  void setFilterConfig(VocabFilterConfig config) {
    filterConfig$.add(config);
    _refilter();
  }

  void clearFilters() {
    filterConfig$.add(const VocabFilterConfig());
    _refilter();
  }

  void toggleCardExpanded(String wordId) {
    final current = Set<String>.from(expandedCards$.value);
    if (current.contains(wordId)) {
      current.remove(wordId);
    } else {
      current.add(wordId);
    }
    expandedCards$.add(current);
  }

  /// Add a word manually (from the Add Word dialog).
  Future<void> addWord(String word) async {
    final normalized = word.toLowerCase().trim();
    if (normalized.isEmpty) return;

    // Check if already saved
    final alreadySaved = await _vocabService.isWordSaved(normalized);
    if (alreadySaved) return;

    await _vocabService.saveWord(
      word: normalized,
      contextSentence: '',
      sourceDocumentId: '',
      sourceDocumentTitle: '',
    );
    await refresh();
  }

  Future<void> deleteWord(String id) async {
    await _vocabRepo.delete(id);
    final updated = allWords$.value.where((w) => w.id != id).toList();
    allWords$.add(updated);
    _refilter();
    _computeStats(updated);
  }

  /// Delete word with undo support. Returns the deleted word for undo.
  Future<VocabularyWordModel?> softDeleteWord(String id) async {
    final all = allWords$.value;
    final index = all.indexWhere((w) => w.id == id);
    if (index == -1) return null;

    final deleted = all[index];
    await _vocabRepo.delete(id);
    final updated = all.where((w) => w.id != id).toList();
    allWords$.add(updated);
    _refilter();
    _computeStats(updated);
    return deleted;
  }

  /// Restore a previously deleted word.
  Future<void> restoreWord(VocabularyWordModel word) async {
    await _vocabRepo.save(word);
    final updated = [...allWords$.value, word];
    allWords$.add(updated);
    _refilter();
    _computeStats(updated);
  }

  Future<void> toggleBookmark(String id) async {
    final all = allWords$.value;
    final index = all.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final word = all[index];
    final updated = word.copyWith(isBookmarked: !word.isBookmarked);
    await _vocabRepo.save(updated);

    final newList = [...all];
    newList[index] = updated;
    allWords$.add(newList);
    _refilter();
  }

  Future<void> cycleDifficulty(String id) async {
    final all = allWords$.value;
    final index = all.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final word = all[index];
    final nextDifficulty = switch (word.difficulty) {
      'easy' => 'medium',
      'medium' => 'hard',
      'hard' => 'easy',
      _ => 'medium',
    };

    final updated = word.copyWith(difficulty: nextDifficulty);
    await _vocabRepo.save(updated);

    final newList = [...all];
    newList[index] = updated;
    allWords$.add(newList);
    _refilter();
    _computeStats(newList);
  }

  Future<int> getDueForReviewCount() async {
    final due = await _vocabService.getReviewSession();
    return due.length;
  }

  /// Get unique source document titles for filter dropdown.
  List<String> get sourceDocuments {
    final sources = allWords$.value
        .map((w) => w.sourceDocumentTitle)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    sources.sort();
    return sources;
  }

  void _refilter() {
    var all = allWords$.value.toList();
    final filter = activeFilter$.value;
    final query = searchQuery$.value;
    final config = filterConfig$.value;

    // Apply mastery filter
    all = switch (filter) {
      'new' || 'fresh' => all.where((w) => w.masteryLevel == 'fresh').toList(),
      'learning' => all.where((w) => w.masteryLevel == 'learning').toList(),
      'mastered' => all.where((w) => w.masteryLevel == 'mastered').toList(),
      'bookmarked' => all.where((w) => w.isBookmarked).toList(),
      _ => all,
    };

    // Apply advanced filters
    if (config.difficulties.isNotEmpty) {
      all = all
          .where((w) => config.difficulties.contains(w.difficulty))
          .toList();
    }
    if (config.sourceDocument != null) {
      all = all
          .where((w) => w.sourceDocumentTitle == config.sourceDocument)
          .toList();
    }
    if (config.dateRange != null) {
      final now = DateTime.now();
      final cutoff = switch (config.dateRange) {
        'today' => DateTime(now.year, now.month, now.day),
        'week' => now.subtract(const Duration(days: 7)),
        'month' => now.subtract(const Duration(days: 30)),
        _ => null,
      };
      if (cutoff != null) {
        all = all.where((w) => w.addedAt.isAfter(cutoff)).toList();
      }
    }

    // Apply search
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      all = all.where((w) {
        return w.word.toLowerCase().contains(lower) ||
            (w.definition?.toLowerCase().contains(lower) ?? false);
      }).toList();
    }

    // Apply sort
    final ascending = sortAscending$.value;
    all.sort((a, b) {
      final cmp = switch (sortOption$.value) {
        VocabSortOption.dateAdded => a.addedAt.compareTo(b.addedAt),
        VocabSortOption.alphabetical => a.word.compareTo(b.word),
        VocabSortOption.difficulty => _difficultyOrder(
          a.difficulty,
        ).compareTo(_difficultyOrder(b.difficulty)),
      };
      return ascending ? cmp : -cmp;
    });

    words$.add(all);
  }

  int _difficultyOrder(String difficulty) {
    return switch (difficulty) {
      'easy' => 0,
      'medium' => 1,
      'hard' => 2,
      _ => 1,
    };
  }

  void _computeStats(List<VocabularyWordModel> words) {
    final now = DateTime.now();
    final mastered = words.where((w) => w.masteryLevel == 'mastered').length;
    final learning = words.where((w) => w.masteryLevel == 'learning').length;
    final fresh = words.where((w) => w.masteryLevel == 'fresh').length;
    final due = words.where((w) {
      final next = w.nextReviewAt;
      return next != null && next.isBefore(now);
    }).length;

    final easy = words.where((w) => w.difficulty == 'easy').length;
    final medium = words.where((w) => w.difficulty == 'medium').length;
    final hard = words.where((w) => w.difficulty == 'hard').length;

    stats$.add(
      VocabularyStats(
        total: words.length,
        mastered: mastered,
        dueForReview: due,
        learning: learning,
        fresh: fresh,
        easy: easy,
        medium: medium,
        hard: hard,
      ),
    );
  }

  void dispose() {
    _searchDebounce?.cancel();
    allWords$.close();
    words$.close();
    activeFilter$.close();
    stats$.close();
    isLoading$.close();
    searchQuery$.close();
    sortOption$.close();
    sortAscending$.close();
    filterConfig$.close();
    expandedCards$.close();
  }
}
