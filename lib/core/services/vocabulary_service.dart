import 'package:uuid/uuid.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';

class VocabularyService {
  final VocabularyRepository _repo;
  final PdfProcessingService _pdfService;
  static const _uuid = Uuid();

  /// Spaced repetition intervals in days
  static const _intervals = AppConstants.spacedRepetitionIntervals;

  /// In-memory cache of saved words for O(1) lookup.
  Set<String>? _savedWordsCache;

  VocabularyService(this._repo, this._pdfService);

  /// Populate the in-memory word cache from the repository.
  Future<void> _ensureCache() async {
    if (_savedWordsCache != null) return;
    final all = await _repo.getAll();
    _savedWordsCache = all.map((w) => w.word).toSet();
  }

  /// Check if a word is already saved in vocabulary.
  Future<bool> isWordSaved(String word) async {
    await _ensureCache();
    final normalized = word.toLowerCase().trim();
    return _savedWordsCache!.contains(normalized);
  }

  /// Remove a saved word from the vocabulary by its raw text. No-op if the
  /// word is not in the library. Keeps the in-memory cache in sync.
  Future<void> removeSavedWord(String word) async {
    await _ensureCache();
    final normalized = word.toLowerCase().trim();
    final all = await _repo.getAll();
    final matches = all.where((w) => w.word == normalized);
    if (matches.isEmpty) return;
    await _repo.delete(matches.first.id);
    _savedWordsCache?.remove(normalized);
  }

  Future<void> saveWord({
    required String word,
    String? definition,
    required String contextSentence,
    required String sourceDocumentId,
    required String sourceDocumentTitle,
    bool isAutoCollected = false,
  }) async {
    final model = VocabularyWordModel(
      id: _uuid.v4(),
      word: word.toLowerCase().trim(),
      definition: definition,
      contextSentence: contextSentence,
      sourceDocumentId: sourceDocumentId,
      sourceDocumentTitle: sourceDocumentTitle,
      addedAt: DateTime.now(),
      nextReviewAt: DateTime.now().add(const Duration(days: 1)),
      isAutoCollected: isAutoCollected,
    );
    await _repo.save(model);
    _savedWordsCache?.add(model.word);
  }

  Future<void> autoCollectFromText(
    String text, {
    required String sourceDocumentId,
    required String sourceDocumentTitle,
  }) async {
    final complexWords = _pdfService.detectComplexWords(text);
    final existing = await _repo.getAll();
    final existingWords = existing.map((w) => w.word).toSet();

    for (final word in complexWords) {
      if (existingWords.contains(word)) continue;
      // Extract context sentence containing the word
      final sentences = text.split(RegExp(r'[.!?]+'));
      final context = sentences.firstWhere(
        (s) => s.toLowerCase().contains(word),
        orElse: () => '',
      );
      if (context.isEmpty) continue;

      await saveWord(
        word: word,
        contextSentence: context.trim(),
        sourceDocumentId: sourceDocumentId,
        sourceDocumentTitle: sourceDocumentTitle,
        isAutoCollected: true,
      );
    }
  }

  Future<List<VocabularyWordModel>> getReviewSession() async {
    return _repo.getDueForReview();
  }

  Future<void> markReviewed(String wordId, {required bool mastered}) async {
    final all = await _repo.getAll();
    final matches = all.where((w) => w.id == wordId);
    if (matches.isEmpty) return;
    final word = matches.first;

    if (mastered) {
      await _repo.save(
        word.copyWith(
          masteryLevel: 'mastered',
          lastReviewedAt: DateTime.now(),
          reviewCount: word.reviewCount + 1,
        ),
      );
    } else {
      final intervalIndex = word.reviewCount.clamp(0, _intervals.length - 1);
      final nextInterval = _intervals[intervalIndex];
      await _repo.save(
        word.copyWith(
          masteryLevel: 'learning',
          lastReviewedAt: DateTime.now(),
          reviewCount: word.reviewCount + 1,
          nextReviewAt: DateTime.now().add(Duration(days: nextInterval)),
        ),
      );
    }
  }
}
