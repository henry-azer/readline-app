import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/core/services/vocabulary_service.dart';
import 'package:readline_app/data/datasources/local/hive_vocabulary_source.dart';
import 'package:readline_app/data/repositories/vocabulary_repository_impl.dart';

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

}
