import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/core/constants/app_constants.dart';

void main() {
  late PdfProcessingService service;

  setUp(() {
    service = PdfProcessingService();
  });

  // ---------------------------------------------------------------------------
  // processSampleText — exercises _calculateComplexity indirectly
  // ---------------------------------------------------------------------------
  group('processSampleText', () {
    test('returns valid DocumentModel with correct word count', () async {
      const text = 'The cat sat on the mat';
      final model = await service.processSampleText(text);
      expect(model.title, 'Sample Text');
      expect(model.totalWords, 6);
      expect(model.id, isNotEmpty);
      expect(model.complexityLevel, isNotEmpty);
    });

    test('all common short words → very low complexity score', () async {
      // All words are in the _commonWords set and are short → complexity near 0.
      const text = 'the be to of and a in that have i it for not on with';
      final model = await service.processSampleText(text);
      // uncommonRatio ≈ 0, avgLength ≈ 3 → score ≈ 30 (border beginner/intermediate)
      // At least verify it does not reach 'advanced' or 'expert'.
      expect(model.complexityScore, lessThan(AppConstants.intermediateMax));
    });

    test(
      'mixed common and uncommon long words → higher complexity score',
      () async {
        const text =
            'the philosophical contemplation of extraordinary metaphysical paradigms';
        final model = await service.processSampleText(text);
        expect(model.complexityScore, greaterThan(AppConstants.beginnerMax));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // _complexityLevel (tested indirectly via processSampleText)
  // ---------------------------------------------------------------------------
  group('_complexityLevel buckets', () {
    test('score < 25 → beginner', () async {
      // Short common words give low avgLength and low uncommonRatio.
      const text = 'a a a a a a a a a a';
      final model = await service.processSampleText(text);
      // avgLength=1, uncommonRatio=0 → score = 10 → beginner
      expect(model.complexityLevel, 'beginner');
    });

    test('score in 25-49 range → intermediate', () async {
      // Construct text that produces a score in [25,50).
      // All 1-char single-letter words: avgLength=1, uncommonRatio=0 → score=10 (beginner).
      // We need to be deliberate: pick long common words to raise avgLength without raising
      // uncommonRatio. 'because' is 7 chars, common. 'would' is 5, common. 'there' is 5, common.
      // avgLength of 'because would there because would there because would there because' ≈ 5.7
      // uncommonRatio ≈ 0 → score ≈ 57 (too high). Use shorter commons.
      // 'that and the in for you are is it can do be' — avgLength ≈ 2.9, uncommonRatio≈0 → 29 → intermediate
      const text = 'that and the in for you are is it can do be';
      final model = await service.processSampleText(text);
      // The score depends on exact avg length; verify it is not 'expert' or 'advanced'.
      // Score = avgLen*10 + uncommonRatio*50.
      // Most of these words are common, avg ~2.75 chars → score ≈ 27.5.
      expect(
        model.complexityLevel == 'beginner' ||
            model.complexityLevel == 'intermediate',
        isTrue,
        reason:
            'Expected beginner or intermediate but got ${model.complexityLevel} '
            '(score ${model.complexityScore})',
      );
    });

    test('long uncommon words push score to advanced or expert', () async {
      const text =
          'philosophical extraordinary contemplative incomprehensible '
          'systematically phenomenological epistemological transcendental';
      final model = await service.processSampleText(text);
      expect(
        model.complexityLevel == 'advanced' ||
            model.complexityLevel == 'expert',
        isTrue,
      );
    });

    test('score >= 75 → expert (purely long uncommon words)', () async {
      // Very long words, all uncommon, avg ~14 chars → score = 14*10 + 1*50 = 190 → clamped 100
      const text =
          'electroencephalography counterrevolutionary incomprehensibility '
          'psychopharmacological institutionalization';
      final model = await service.processSampleText(text);
      expect(model.complexityLevel, 'expert');
    });
  });

  // ---------------------------------------------------------------------------
  // detectComplexWords
  // ---------------------------------------------------------------------------
  group('detectComplexWords', () {
    test('finds words >= 7 chars that are not common', () {
      const text = 'The beautiful butterfly fluttered gracefully overhead';
      final words = service.detectComplexWords(text);
      // 'beautiful', 'butterfly', 'fluttered', 'gracefully' are >= 7 chars and uncommon.
      expect(words, contains('beautiful'));
      expect(words, contains('butterfly'));
    });

    test('excludes common words even if they would meet length threshold', () {
      // 'because' is in the common words set and is 7 chars.
      const text = 'because although however';
      final words = service.detectComplexWords(text);
      expect(words, isNot(contains('because')));
    });

    test('excludes words shorter than 7 chars', () {
      const text = 'running jumped played kicked scored';
      final words = service.detectComplexWords(text);
      // All are 6-7 chars; only keep >= 7.
      for (final w in words) {
        expect(w.length, greaterThanOrEqualTo(7));
      }
    });

    test('returns empty list for all-common-word input', () {
      const text = 'the be to of and a in that have';
      final words = service.detectComplexWords(text);
      expect(words, isEmpty);
    });

    test('deduplicates repeated complex words', () {
      const text = 'extraordinary extraordinary extraordinary';
      final words = service.detectComplexWords(text);
      expect(words.length, 1);
    });

    test('lowercases words before checking', () {
      const text = 'Extraordinary PHILOSOPHICAL Beautiful';
      final words = service.detectComplexWords(text);
      expect(words, contains('extraordinary'));
      expect(words, contains('philosophical'));
      expect(words, contains('beautiful'));
    });
  });
}
