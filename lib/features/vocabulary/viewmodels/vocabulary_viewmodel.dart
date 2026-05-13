import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/dictionary_service.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';

class VocabularyStats {
  final int total;
  final int easy;
  final int medium;
  final int hard;

  const VocabularyStats({
    this.total = 0,
    this.easy = 0,
    this.medium = 0,
    this.hard = 0,
  });
}

class VocabularyViewModel {
  final VocabularyRepository _vocabRepo;
  final PreferencesRepository _prefsRepo;
  final DictionaryService _dictionaryService;
  final PdfProcessingService _pdfService;

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
  final BehaviorSubject<Set<String>> expandedCards$ = BehaviorSubject.seeded(
    const {},
  );

  // Words we've already attempted to enrich this session (success or fail).
  // Prevents repeated network calls for words the dictionary doesn't return.
  final Set<String> _backfillAttempted = {};

  VocabularyViewModel({
    VocabularyRepository? vocabRepo,
    PreferencesRepository? prefsRepo,
    DictionaryService? dictionaryService,
    PdfProcessingService? pdfService,
  }) : _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>(),
       _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _dictionaryService = dictionaryService ?? getIt<DictionaryService>(),
       _pdfService = pdfService ?? getIt<PdfProcessingService>() {
    final words = _vocabRepo.cachedAll;
    if (words.isNotEmpty) {
      allWords$.add(words);
      _refilter();
      _computeStats(words);
    }
  }

  Future<void> init() async {
    await refresh();

    final prefs = await _prefsRepo.get();
    if (!prefs.vocabDifficultyBackfilled) {
      unawaited(_runDifficultyBackfill());
    }
  }

  /// Reclassifies words still at the legacy "medium" default using the
  /// length+common-word heuristic. Runs once per install (gated by
  /// [UserPreferencesModel.vocabDifficultyBackfilled]) so any deliberate
  /// [cycleDifficulty] choices the user makes after stick across sessions.
  Future<void> _runDifficultyBackfill() async {
    final words = allWords$.value;
    if (words.isEmpty) {
      final current = await _prefsRepo.get();
      await _prefsRepo.save(
        current.copyWith(vocabDifficultyBackfilled: true),
      );
      return;
    }

    var changed = false;
    for (final w in words) {
      if (w.difficulty != 'medium') continue;
      final classified = _pdfService.classifyDifficulty(w.word);
      if (classified == 'medium') continue;
      await _vocabRepo.save(w.copyWith(difficulty: classified));
      changed = true;
    }

    final current = await _prefsRepo.get();
    await _prefsRepo.save(
      current.copyWith(vocabDifficultyBackfilled: true),
    );

    if (!changed || allWords$.isClosed) return;
    final fresh = await _vocabRepo.getAll();
    if (allWords$.isClosed) return;
    allWords$.add(fresh);
    _refilter();
    _computeStats(fresh);
  }

  Future<void> refresh() async {
    final silent = allWords$.value.isNotEmpty;
    if (!silent) isLoading$.add(true);
    try {
      final words = await _vocabRepo.getAll();
      allWords$.add(words);
      _refilter();
      _computeStats(words);
    } finally {
      if (!silent) isLoading$.add(false);
    }
    unawaited(_backfillEnrichment());
  }

  /// Backfills [VocabularyWordModel.partOfSpeech] / [phonetic] /
  /// [exampleSentence] / [definition] for words saved before those fields were
  /// captured (e.g. via auto-collect). Lookups are cache-first; uncached words
  /// hit the dictionary API once per session — failures get tracked in
  /// [_backfillAttempted] so we don't keep retrying the same misses.
  Future<void> _backfillEnrichment() async {
    final candidates = allWords$.value
        .where(
          (w) =>
              !_backfillAttempted.contains(w.word) &&
              (w.partOfSpeech == null || w.partOfSpeech!.isEmpty) &&
              (w.phonetic == null || w.phonetic!.isEmpty),
        )
        .toList();
    if (candidates.isEmpty) return;

    var changed = false;
    // Look up in parallel — cache hits resolve instantly; uncached words
    // share the 3 s timeout window concurrently instead of serializing.
    final results = await Future.wait(
      candidates.map((w) => _dictionaryService.lookupWord(w.word)),
    );

    for (var i = 0; i < candidates.length; i++) {
      final w = candidates[i];
      _backfillAttempted.add(w.word);
      final def = results[i].definition;
      if (def == null) continue;
      final pos = def.partOfSpeech.isNotEmpty ? def.partOfSpeech : null;
      final phon = (def.phonetic?.isNotEmpty ?? false) ? def.phonetic : null;
      final defText = def.definition.isNotEmpty ? def.definition : null;
      if (pos == null &&
          phon == null &&
          def.exampleSentence == null &&
          defText == null) {
        continue;
      }
      await _vocabRepo.save(
        w.copyWith(
          definition: defText ?? w.definition,
          partOfSpeech: pos,
          phonetic: phon,
          exampleSentence: def.exampleSentence,
        ),
      );
      changed = true;
    }
    if (!changed || allWords$.isClosed) return;

    final fresh = await _vocabRepo.getAll();
    if (allWords$.isClosed) return;
    allWords$.add(fresh);
    _refilter();
    _computeStats(fresh);
  }

  void setFilter(String filter) {
    activeFilter$.add(filter);
    _refilter();
  }

  void setSearchQuery(String query) {
    searchQuery$.add(query);
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

  void _refilter() {
    var all = allWords$.value.toList();
    final filter = activeFilter$.value;
    final query = searchQuery$.value;

    all = switch (filter) {
      'easy' => all.where((w) => w.difficulty == 'easy').toList(),
      'medium' => all.where((w) => w.difficulty == 'medium').toList(),
      'hard' => all.where((w) => w.difficulty == 'hard').toList(),
      _ => all,
    };

    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      all = all.where((w) => w.word.toLowerCase().contains(lower)).toList();
    }

    // Newest first by addedAt.
    all.sort((a, b) => b.addedAt.compareTo(a.addedAt));

    words$.add(all);
  }

  void _computeStats(List<VocabularyWordModel> words) {
    final easy = words.where((w) => w.difficulty == 'easy').length;
    final medium = words.where((w) => w.difficulty == 'medium').length;
    final hard = words.where((w) => w.difficulty == 'hard').length;

    stats$.add(
      VocabularyStats(
        total: words.length,
        easy: easy,
        medium: medium,
        hard: hard,
      ),
    );
  }

  void dispose() {
    allWords$.close();
    words$.close();
    activeFilter$.close();
    stats$.close();
    isLoading$.close();
    searchQuery$.close();
    expandedCards$.close();
  }
}
