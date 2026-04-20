import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';
import 'package:read_it/core/services/vocabulary_service.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/data/datasources/local/hive_vocabulary_source.dart';
import 'package:read_it/data/repositories/vocabulary_repository_impl.dart';

void main() {
  late Directory tempDir;
  late VocabularyService service;
  late VocabularyRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vocab_test');
    Hive.init(tempDir.path);
    final source = HiveVocabularySource();
    repo = VocabularyRepositoryImpl(source);
    final pdfService = PdfProcessingService();
    service = VocabularyService(repo, pdfService);
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  // ---------------------------------------------------------------------------
  // saveWord
  // ---------------------------------------------------------------------------
  group('saveWord', () {
    test('creates a word that appears in repo.getAll()', () async {
      await service.saveWord(
        word: 'eloquent',
        contextSentence: 'She gave an eloquent speech.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Test Doc',
      );
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.word, 'eloquent');
    });

    test('normalises word to lowercase', () async {
      await service.saveWord(
        word: 'ELOQUENT',
        contextSentence: 'Context here.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Test Doc',
      );
      final all = await repo.getAll();
      expect(all.first.word, 'eloquent');
    });

    test('trims leading and trailing whitespace from word', () async {
      await service.saveWord(
        word: '  beautiful  ',
        contextSentence: 'A beautiful day.',
        sourceDocumentId: 'doc-2',
        sourceDocumentTitle: 'Test Doc 2',
      );
      final all = await repo.getAll();
      expect(all.first.word, 'beautiful');
    });

    test('sets default masteryLevel to "fresh"', () async {
      await service.saveWord(
        word: 'innovative',
        contextSentence: 'An innovative solution.',
        sourceDocumentId: 'doc-3',
        sourceDocumentTitle: 'Test Doc 3',
      );
      final all = await repo.getAll();
      expect(all.first.masteryLevel, 'fresh');
    });

    test('nextReviewAt is set to approximately 1 day from now', () async {
      final before = DateTime.now();
      await service.saveWord(
        word: 'perspective',
        contextSentence: 'A new perspective.',
        sourceDocumentId: 'doc-4',
        sourceDocumentTitle: 'Test Doc 4',
      );
      final after = DateTime.now();
      final all = await repo.getAll();
      final nextReview = all.first.nextReviewAt!;
      expect(nextReview.isAfter(before.add(const Duration(hours: 23))), isTrue);
      expect(nextReview.isBefore(after.add(const Duration(days: 2))), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // autoCollectFromText
  // ---------------------------------------------------------------------------
  group('autoCollectFromText', () {
    test('finds complex words (>= 7 chars, not common) in text', () async {
      const text =
          'The philosophical contemplation of extraordinary ideas is remarkable.';
      await service.autoCollectFromText(
        text,
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Philosophy Doc',
      );
      final all = await repo.getAll();
      final words = all.map((w) => w.word).toList();
      // 'philosophical', 'contemplation', 'extraordinary', 'remarkable' are >= 7 chars
      expect(words.any((w) => w.length >= 7), isTrue);
    });

    test('does not collect words shorter than 7 chars', () async {
      const text = 'The cat sat on the big mat today.';
      await service.autoCollectFromText(
        text,
        sourceDocumentId: 'doc-2',
        sourceDocumentTitle: 'Short Doc',
      );
      final all = await repo.getAll();
      for (final w in all) {
        expect(w.word.length, greaterThanOrEqualTo(7));
      }
    });

    test('deduplicates against existing words in repo', () async {
      // Pre-save a word.
      await service.saveWord(
        word: 'philosophical',
        contextSentence: 'philosophical thinking is great.',
        sourceDocumentId: 'doc-0',
        sourceDocumentTitle: 'Pre-existing',
      );
      const text = 'The philosophical contemplation of extraordinary ideas.';
      await service.autoCollectFromText(
        text,
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Philosophy Doc',
      );
      final all = await repo.getAll();
      final philosophicalWords = all
          .where((w) => w.word == 'philosophical')
          .toList();
      // Must appear only once.
      expect(philosophicalWords.length, 1);
    });

    test('empty text collects nothing', () async {
      await service.autoCollectFromText(
        '',
        sourceDocumentId: 'doc-3',
        sourceDocumentTitle: 'Empty',
      );
      final all = await repo.getAll();
      expect(all, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // markReviewed — mastered
  // ---------------------------------------------------------------------------
  group('markReviewed mastered=true', () {
    test('sets masteryLevel to "mastered"', () async {
      await service.saveWord(
        word: 'eloquent',
        contextSentence: 'Eloquent speech.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Doc',
      );
      final all = await repo.getAll();
      final wordId = all.first.id;
      await service.markReviewed(wordId, mastered: true);
      final updated = await repo.getAll();
      expect(updated.first.masteryLevel, 'mastered');
    });

    test('increments reviewCount', () async {
      await service.saveWord(
        word: 'remarkable',
        contextSentence: 'A remarkable feat.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Doc',
      );
      final all = await repo.getAll();
      expect(all.first.reviewCount, 0);
      await service.markReviewed(all.first.id, mastered: true);
      final updated = await repo.getAll();
      expect(updated.first.reviewCount, 1);
    });

    test('sets lastReviewedAt to now', () async {
      await service.saveWord(
        word: 'magnificent',
        contextSentence: 'A magnificent view.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Doc',
      );
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final all = await repo.getAll();
      await service.markReviewed(all.first.id, mastered: true);
      final updated = await repo.getAll();
      expect(updated.first.lastReviewedAt, isNotNull);
      expect(updated.first.lastReviewedAt!.isAfter(before), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // markReviewed — not mastered (learning)
  // ---------------------------------------------------------------------------
  group('markReviewed mastered=false', () {
    test('sets masteryLevel to "learning"', () async {
      await service.saveWord(
        word: 'perplexing',
        contextSentence: 'A perplexing puzzle.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Doc',
      );
      final all = await repo.getAll();
      await service.markReviewed(all.first.id, mastered: false);
      final updated = await repo.getAll();
      expect(updated.first.masteryLevel, 'learning');
    });

    test(
      'schedules nextReviewAt based on spaced repetition interval',
      () async {
        await service.saveWord(
          word: 'phenomenal',
          contextSentence: 'A phenomenal result.',
          sourceDocumentId: 'doc-1',
          sourceDocumentTitle: 'Doc',
        );
        final all = await repo.getAll();
        final before = DateTime.now();
        await service.markReviewed(all.first.id, mastered: false);
        final updated = await repo.getAll();
        // reviewCount was 0, so intervalIndex = 0, interval = 1 day
        final expectedInterval =
            AppConstants.spacedRepetitionIntervals[0]; // 1 day
        final nextReview = updated.first.nextReviewAt!;
        final diff = nextReview.difference(before).inHours;
        expect(diff, greaterThanOrEqualTo(23));
        expect(diff, lessThan(expectedInterval * 24 + 1));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Spaced repetition interval progression
  // ---------------------------------------------------------------------------
  group('spaced repetition', () {
    test('interval increases with reviewCount', () async {
      await service.saveWord(
        word: 'extraordinary',
        contextSentence: 'An extraordinary event.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Doc',
      );
      final all = await repo.getAll();
      final wordId = all.first.id;

      // First not-mastered review: reviewCount=0 → interval[0]=1 day
      await service.markReviewed(wordId, mastered: false);
      final after1 = await repo.getAll();
      final nextReview1 = after1.first.nextReviewAt!;
      expect(after1.first.reviewCount, 1);

      // Second not-mastered review: reviewCount=1 → interval[1]=3 days
      await service.markReviewed(wordId, mastered: false);
      final after2 = await repo.getAll();
      final nextReview2 = after2.first.nextReviewAt!;
      expect(after2.first.reviewCount, 2);

      // nextReview2 should be farther in the future than nextReview1
      expect(nextReview2.isAfter(nextReview1), isTrue);
    });

    test(
      'interval is clamped at last entry for very high reviewCount',
      () async {
        await service.saveWord(
          word: 'elaborate',
          contextSentence: 'An elaborate plan.',
          sourceDocumentId: 'doc-1',
          sourceDocumentTitle: 'Doc',
        );
        // Manually set reviewCount to beyond the intervals list length.
        final all = await repo.getAll();
        final word = all.first;
        // Simulate 10 reviews done (intervals list has 5 entries, so clamp to 4)
        await repo.save(word.copyWith(reviewCount: 10));
        await service.markReviewed(word.id, mastered: false);
        final updated = await repo.getAll();
        // Should use intervals[4] = 30 days, not crash.
        final maxInterval = AppConstants.spacedRepetitionIntervals.last;
        final diff = updated.first.nextReviewAt!
            .difference(DateTime.now())
            .inDays;
        expect(diff, greaterThanOrEqualTo(maxInterval - 1));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // getReviewSession
  // ---------------------------------------------------------------------------
  group('getReviewSession', () {
    test(
      'returns words due for review (not mastered, nextReviewAt in past)',
      () async {
        await service.saveWord(
          word: 'illustrious',
          contextSentence: 'An illustrious career.',
          sourceDocumentId: 'doc-1',
          sourceDocumentTitle: 'Doc',
        );
        // Fresh words have nextReviewAt ~1 day from now, so not due yet.
        // But word is 'fresh' with nextReviewAt set to 1 day from now.
        // For it to be due, override nextReviewAt to past.
        final all = await repo.getAll();
        final word = all.first.copyWith(
          nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        await repo.save(word);
        final session = await service.getReviewSession();
        expect(session.any((w) => w.word == 'illustrious'), isTrue);
      },
    );

    test('does not return mastered words', () async {
      await service.saveWord(
        word: 'superlative',
        contextSentence: 'A superlative result.',
        sourceDocumentId: 'doc-1',
        sourceDocumentTitle: 'Doc',
      );
      final all = await repo.getAll();
      await service.markReviewed(all.first.id, mastered: true);
      final session = await service.getReviewSession();
      expect(session.any((w) => w.word == 'superlative'), isFalse);
    });
  });
}
