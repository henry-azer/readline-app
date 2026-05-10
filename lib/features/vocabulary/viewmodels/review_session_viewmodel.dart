import 'package:rxdart/rxdart.dart';
import 'package:readline_app/app.dart' show vocabChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/vocabulary_service.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';

class ReviewSessionResults {
  final int totalReviewed;
  final int mastered;
  final int stillLearning;

  const ReviewSessionResults({
    this.totalReviewed = 0,
    this.mastered = 0,
    this.stillLearning = 0,
  });

  double get accuracy => totalReviewed == 0 ? 0 : mastered / totalReviewed;
}

class ReviewSessionViewModel {
  final VocabularyService _vocabService;

  final BehaviorSubject<List<VocabularyWordModel>> words$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<int> currentIndex$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<bool> isFlipped$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> isComplete$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<ReviewSessionResults> results$ = BehaviorSubject.seeded(
    const ReviewSessionResults(),
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);

  /// Fires once at session end with the final results, but only when the
  /// user actually reviewed at least one word. Empty-deck completions are
  /// handled by the no-words view in the screen body instead.
  final PublishSubject<ReviewSessionResults> summaryReady$ =
      PublishSubject<ReviewSessionResults>();

  ReviewSessionViewModel({VocabularyService? vocabService})
    : _vocabService = vocabService ?? getIt<VocabularyService>();

  List<VocabularyWordModel> get words => words$.value;

  VocabularyWordModel? get currentWord {
    final list = words$.value;
    final idx = currentIndex$.value;
    if (list.isEmpty || idx >= list.length) return null;
    return list[idx];
  }

  Future<void> init() async {
    isLoading$.add(true);
    try {
      final sessionWords = await _vocabService.getReviewSession();
      words$.add(sessionWords);
      currentIndex$.add(0);
      isFlipped$.add(false);
      isComplete$.add(sessionWords.isEmpty);
    } finally {
      isLoading$.add(false);
    }
  }

  void flipCard() {
    isFlipped$.add(!isFlipped$.value);
  }

  Future<void> markMastered() async {
    final word = currentWord;
    if (word == null) return;

    await _vocabService.markReviewed(word.id, mastered: true);

    final current = results$.value;
    results$.add(
      ReviewSessionResults(
        totalReviewed: current.totalReviewed + 1,
        mastered: current.mastered + 1,
        stillLearning: current.stillLearning,
      ),
    );

    await _advance();
  }

  Future<void> markLearning() async {
    final word = currentWord;
    if (word == null) return;

    await _vocabService.markReviewed(word.id, mastered: false);

    final current = results$.value;
    results$.add(
      ReviewSessionResults(
        totalReviewed: current.totalReviewed + 1,
        mastered: current.mastered,
        stillLearning: current.stillLearning + 1,
      ),
    );

    await _advance();
  }

  Future<void> _advance() async {
    final nextIndex = currentIndex$.value + 1;
    if (nextIndex >= words$.value.length) {
      isComplete$.add(true);
      // Refresh the vocabulary screen so the "Start Session" CTA hides
      // once the just-reviewed words drop out of the due bucket.
      vocabChangeNotifier.value++;
      final results = results$.value;
      if (results.totalReviewed > 0) {
        summaryReady$.add(results);
      }
    } else {
      currentIndex$.add(nextIndex);
      isFlipped$.add(false);
    }
  }

  void dispose() {
    words$.close();
    currentIndex$.close();
    isFlipped$.close();
    isComplete$.close();
    results$.close();
    isLoading$.close();
    summaryReady$.close();
  }
}
