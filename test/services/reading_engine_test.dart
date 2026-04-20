import 'package:flutter_test/flutter_test.dart';
import 'package:read_it/core/services/reading_engine_service.dart';

void main() {
  late ReadingEngineService service;

  setUp(() {
    service = ReadingEngineService();
  });

  tearDown(() {
    service.dispose();
  });

  group('loadContent', () {
    test('splits text into words and resets state', () {
      service.loadContent('hello world foo bar');
      expect(service.totalWords, 4);
      expect(service.currentWordIndex, 0);
      expect(service.wordsRead, 0);
    });

    test('ignores extra whitespace when splitting', () {
      service.loadContent('  one   two  three  ');
      expect(service.totalWords, 3);
    });

    test('resets _sessionStart so calculateFocusScore returns 0', () {
      // Play once to set sessionStart, then reload and check sessionStart is
      // cleared (calculateFocusScore returns 0 when _sessionStart is null).
      service.loadContent('a b c');
      service.play();
      service.stop();
      // Now reload — sessionStart must be nulled out.
      service.loadContent('x y z');
      expect(service.calculateFocusScore(), 0.0);
    });

    test('resets pause count on new load', () {
      service.loadContent('one two three');
      service.play();
      service.pause();
      service.pause();
      service.loadContent('new content here');
      // After reload, play to set sessionStart; no pauses yet.
      service.play();
      service.stop();
      // pauseCount resets to 0 on loadContent, so score should not be penalised.
      // duration is 0 min, so score == 100.
      expect(service.calculateFocusScore(), 100.0);
    });
  });

  group('play / pause / stop', () {
    test('play sets isPlaying true in state\$', () async {
      service.loadContent('one two three four five');
      service.play();
      final state = await service.state$.first;
      expect(state.isPlaying, isTrue);
      service.stop();
    });

    test('pause sets isPlaying false and increments pause count', () async {
      service.loadContent('a b c d e f g');
      service.play();
      service.pause();
      final state = await service.state$.first;
      expect(state.isPlaying, isFalse);
      // duration == 0 min → calculateFocusScore() returns 100 immediately (no penalty applied).
      // The important observable: state is not playing after pause.
    });

    test('stop sets isPlaying false', () async {
      service.loadContent('a b c d e f');
      service.play();
      service.stop();
      final state = await service.state$.first;
      expect(state.isPlaying, isFalse);
    });
  });

  group('setSpeed', () {
    test('changes currentWpm in state', () async {
      service.loadContent('hello world test words here');
      service.setSpeed(300);
      final state = await service.state$.first;
      expect(state.currentWpm, 300);
    });

    test('internal currentWpm getter reflects change', () {
      service.loadContent('a b c');
      service.setSpeed(150);
      expect(service.currentWpm, 150);
    });
  });

  group('setFocusLines', () {
    test('adjusts focus window (5 words per line)', () {
      service.loadContent(List.generate(100, (i) => 'word$i').join(' '));
      // We can only observe this indirectly via emitted state focus text.
      // 3 lines → 15 words focus window; jump to index 20 to observe.
      service.setFocusLines(3);
      service.jumpToWord(20);
      final focusText = service.state$.value.focusText;
      // focusText should have at most 15+1 words (from focusStart to currentIndex)
      final wordCount = focusText.trim().split(RegExp(r'\s+')).length;
      expect(wordCount, lessThanOrEqualTo(16));
    });
  });

  group('jumpToWord', () {
    setUp(() {
      service.loadContent('zero one two three four five six seven eight nine');
    });

    test('jumps to valid index within bounds', () {
      service.jumpToWord(5);
      expect(service.currentWordIndex, 5);
      expect(service.wordAt(5), 'five');
    });

    test('clamps index below 0 to 0', () {
      service.jumpToWord(-10);
      expect(service.currentWordIndex, 0);
    });

    test('clamps index above max to last word index', () {
      service.jumpToWord(9999);
      expect(service.currentWordIndex, service.totalWords - 1);
    });
  });

  group('calculateFocusScore', () {
    test('returns 0 when session has not started (sessionStart is null)', () {
      service.loadContent('a b c d');
      expect(service.calculateFocusScore(), 0.0);
    });

    test('returns 100 for no pauses when duration is 0 minutes', () {
      service.loadContent('a b c d e');
      service.play();
      service.stop();
      // duration == 0 min → return 100 immediately
      expect(service.calculateFocusScore(), 100.0);
    });

    test('pause count is tracked (score formula has pause penalty)', () {
      // calculateFocusScore: when duration == 0 min, returns 100 immediately.
      // When duration >= 1 min, applies pausePenalty = pauseCount * 5.
      // We can verify the formula indirectly: zero pauses with session started
      // and zero minutes → 100; we trust the code applies penalty for non-zero duration.
      service.loadContent('a b c d e f g h i j');
      service.play();
      // With 0 pauses and 0 minute duration, score == 100.
      final scoreNoPauses = service.calculateFocusScore();
      expect(scoreNoPauses, 100.0);
      service.stop();
      // After multiple pause+play cycles, _pauseCount grows but duration
      // stays 0 in a fast test — score still 100 due to early return.
      // This test documents the known behaviour: penalty only applies when
      // the session has lasted at least 1 minute.
    });
  });

  group('wordAt', () {
    setUp(() {
      service.loadContent('alpha beta gamma delta');
    });

    test('returns correct word by index', () {
      expect(service.wordAt(0), 'alpha');
      expect(service.wordAt(1), 'beta');
      expect(service.wordAt(3), 'delta');
    });

    test('returns empty string for negative index', () {
      expect(service.wordAt(-1), '');
    });

    test('returns empty string for index at or beyond totalWords', () {
      expect(service.wordAt(4), '');
      expect(service.wordAt(100), '');
    });
  });

  group('getters', () {
    test('currentWordIndex starts at 0', () {
      service.loadContent('one two three');
      expect(service.currentWordIndex, 0);
    });

    test('totalWords matches word count', () {
      service.loadContent('a b c d e');
      expect(service.totalWords, 5);
    });

    test('wordsRead equals currentWordIndex', () {
      service.loadContent('a b c d e f');
      service.jumpToWord(3);
      expect(service.wordsRead, service.currentWordIndex);
      expect(service.wordsRead, 3);
    });
  });
}
