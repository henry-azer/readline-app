import 'package:uuid/uuid.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/data/contracts/vocabulary_repository.dart';
import 'package:read_it/data/models/vocabulary_word_model.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';

class VocabularyService {
  final VocabularyRepository _repo;
  final PdfProcessingService _pdfService;
  static const _uuid = Uuid();

  /// Spaced repetition intervals in days
  static const _intervals = AppConstants.spacedRepetitionIntervals;

  VocabularyService(this._repo, this._pdfService);

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
