import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/services/vocabulary_service.dart';
import 'package:read_it/data/contracts/vocabulary_repository.dart';
import 'package:read_it/data/models/vocabulary_word_model.dart';

class VocabularyStats {
  final int total;
  final int mastered;
  final int dueForReview;
  final int learning;
  final int fresh;

  const VocabularyStats({
    this.total = 0,
    this.mastered = 0,
    this.dueForReview = 0,
    this.learning = 0,
    this.fresh = 0,
  });
}

class VocabularyViewModel {
  final VocabularyRepository _vocabRepo;
  final VocabularyService _vocabService;

  final BehaviorSubject<List<VocabularyWordModel>> allWords$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<List<VocabularyWordModel>> words$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<String> activeFilter$ = BehaviorSubject.seeded('all');
  final BehaviorSubject<VocabularyStats> stats$ = BehaviorSubject.seeded(
    const VocabularyStats(),
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);

  VocabularyViewModel({
    VocabularyRepository? vocabRepo,
    VocabularyService? vocabService,
  }) : _vocabRepo = vocabRepo ?? getIt<VocabularyRepository>(),
       _vocabService = vocabService ?? getIt<VocabularyService>();

  String get currentFilter => activeFilter$.value;
  int get wordCount => allWords$.value.length;
  List<VocabularyWordModel> get currentWords => words$.value;

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      final words = await _vocabRepo.getAll();
      allWords$.add(words);
      _applyFilter(activeFilter$.value);
      _computeStats(words);
    } finally {
      isLoading$.add(false);
    }
  }

  void setFilter(String filter) {
    activeFilter$.add(filter);
    _applyFilter(filter);
  }

  Future<void> deleteWord(String id) async {
    await _vocabRepo.delete(id);
    final updated = allWords$.value.where((w) => w.id != id).toList();
    allWords$.add(updated);
    _applyFilter(activeFilter$.value);
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
    _applyFilter(activeFilter$.value);
  }

  Future<int> getDueForReviewCount() async {
    final due = await _vocabService.getReviewSession();
    return due.length;
  }

  void _applyFilter(String filter) {
    final all = allWords$.value;
    final filtered = switch (filter) {
      'new' || 'fresh' => all.where((w) => w.masteryLevel == 'fresh').toList(),
      'learning' => all.where((w) => w.masteryLevel == 'learning').toList(),
      'mastered' => all.where((w) => w.masteryLevel == 'mastered').toList(),
      'bookmarked' => all.where((w) => w.isBookmarked).toList(),
      _ => all,
    };
    words$.add(filtered);
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

    stats$.add(
      VocabularyStats(
        total: words.length,
        mastered: mastered,
        dueForReview: due,
        learning: learning,
        fresh: fresh,
      ),
    );
  }

  void dispose() {
    allWords$.close();
    words$.close();
    activeFilter$.close();
    stats$.close();
    isLoading$.close();
  }
}
