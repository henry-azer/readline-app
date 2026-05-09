import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/utils/document_meta.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppLocalization.initialize();
  });

  group('DocumentMeta.wordCount', () {
    test('formats small numbers without separator', () {
      expect(DocumentMeta.wordCount(0), '0');
      expect(DocumentMeta.wordCount(1), '1');
      expect(DocumentMeta.wordCount(999), '999');
    });

    test('formats four-digit numbers with thousands separator', () {
      expect(DocumentMeta.wordCount(1000), '1,000');
      expect(DocumentMeta.wordCount(1234), '1,234');
    });

    test('formats large numbers with multiple separators', () {
      expect(DocumentMeta.wordCount(123456), '123,456');
      expect(DocumentMeta.wordCount(1234567), '1,234,567');
    });
  });

  group('DocumentMeta.estimatedTime', () {
    DocumentModel doc({
      required int totalWords,
      required int wordsRead,
      String status = 'unread',
    }) {
      return DocumentModel(
        id: 'x',
        title: 't',
        totalWords: totalWords,
        wordsRead: wordsRead,
        readingStatus: status,
        importedAt: DateTime(2026, 1, 1),
      );
    }

    test('returns null when wpm is zero or negative', () {
      expect(
        DocumentMeta.estimatedTime(doc(totalWords: 1000, wordsRead: 0), 0),
        isNull,
      );
      expect(
        DocumentMeta.estimatedTime(doc(totalWords: 1000, wordsRead: 0), -1),
        isNull,
      );
    });

    test('returns null when totalWords is zero', () {
      expect(
        DocumentMeta.estimatedTime(doc(totalWords: 0, wordsRead: 0), 200),
        isNull,
      );
    });

    test('returns total time for unread documents', () {
      // 4000 words / 200 wpm = 20 min
      final result = DocumentMeta.estimatedTime(
        doc(totalWords: 4000, wordsRead: 0),
        200,
      );
      expect(result, contains('20'));
      expect(result, contains('total'));
    });

    test('returns total time for completed documents', () {
      // 2000 words / 200 wpm = 10 min total (uses totalWords, not remaining)
      final result = DocumentMeta.estimatedTime(
        doc(totalWords: 2000, wordsRead: 2000, status: 'completed'),
        200,
      );
      expect(result, contains('10'));
      expect(result, contains('total'));
    });

    test('returns time-left for in-progress documents', () {
      // 1000 words remaining (3000 total - 2000 read) / 200 wpm = 5 min
      final result = DocumentMeta.estimatedTime(
        doc(totalWords: 3000, wordsRead: 2000),
        200,
      );
      expect(result, contains('5'));
      expect(result, contains('left'));
    });

    test('rounds up partial minutes', () {
      // 50 words / 200 wpm = 0.25 min → ceil to 1
      final result = DocumentMeta.estimatedTime(
        doc(totalWords: 50, wordsRead: 0),
        200,
      );
      expect(result, contains('1'));
    });

    test('handles tiny totals via the unread/total branch', () {
      // 1 word / 100000 wpm → 0.00001 min → ceil to 1
      final result = DocumentMeta.estimatedTime(
        doc(totalWords: 1, wordsRead: 0),
        100000,
      );
      expect(result, contains('1'));
    });
  });
}
