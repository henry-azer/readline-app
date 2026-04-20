import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/data/entities/reading_state.dart';

class ReadingEngineService {
  final BehaviorSubject<ReadingState> state$ = BehaviorSubject.seeded(
    const ReadingState(),
  );

  Timer? _scrollTimer;
  List<String> _words = [];
  int _currentIndex = 0;
  int _wpm = AppConstants.defaultWpm;
  int _focusWindowWords = 15; // ~3 lines of focus text
  int _pauseCount = 0;
  DateTime? _sessionStart;

  void loadContent(
    String text, {
    int wpm = AppConstants.defaultWpm,
    int focusLines = 3,
  }) {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    _currentIndex = 0;
    _wpm = wpm;
    _focusWindowWords = focusLines * 5; // ~5 words per line
    _pauseCount = 0;
    _sessionStart = null;
    _emitState();
  }

  void resumeFromPosition(int wordIndex) {
    _currentIndex = wordIndex.clamp(0, _words.length - 1);
    _emitState();
  }

  void play() {
    if (_words.isEmpty) return;
    _sessionStart ??= DateTime.now();

    final msPerWord = (60000 / _wpm).round();
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(Duration(milliseconds: msPerWord), (_) {
      if (_currentIndex >= _words.length - 1) {
        stop();
        state$.add(state$.value.copyWith(isComplete: true));
        return;
      }
      _currentIndex++;
      _emitState();
    });

    state$.add(state$.value.copyWith(isPlaying: true));
  }

  void pause() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _pauseCount++;
    state$.add(state$.value.copyWith(isPlaying: false));
  }

  void stop() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    state$.add(state$.value.copyWith(isPlaying: false));
  }

  void setSpeed(int wpm) {
    _wpm = wpm;
    state$.add(state$.value.copyWith(currentWpm: wpm));
    if (state$.value.isPlaying) {
      pause();
      play();
    }
  }

  void setFocusLines(int lines) {
    _focusWindowWords = lines * 5;
    _emitState();
  }

  void jumpToWord(int index) {
    _currentIndex = index.clamp(0, _words.length - 1);
    _emitState();
  }

  void highlightWord(String? word) {
    state$.add(state$.value.copyWith(highlightedWord: word));
  }

  /// Calculate focus score (0-100) based on session behavior
  double calculateFocusScore() {
    if (_sessionStart == null) return 0;
    final duration = DateTime.now().difference(_sessionStart!).inMinutes;
    if (duration == 0) return 100;
    // Fewer pauses and longer sessions = higher score
    final pausePenalty = (_pauseCount * 5).clamp(0, 50);
    final durationBonus = (duration * 2).clamp(0, 50);
    return (100 - pausePenalty + durationBonus).clamp(0, 100).toDouble();
  }

  int get currentWordIndex => _currentIndex;
  int get totalWords => _words.length;
  int get wordsRead => _currentIndex;
  int get currentWpm => _wpm;

  String wordAt(int index) {
    if (index < 0 || index >= _words.length) return '';
    return _words[index];
  }

  void _emitState() {
    // focusStart: beginning of the focus window (the actively highlighted zone)
    final focusStart = (_currentIndex - _focusWindowWords).clamp(
      0,
      _words.length,
    );

    // Past text: up to ~50 words before the focus window
    final pastStart = (focusStart - 50).clamp(0, _words.length);
    final pastText = _words.sublist(pastStart, focusStart).join(' ');
    // Focus text: the current focus window up to the current word
    final focusText = _words.sublist(focusStart, _currentIndex + 1).join(' ');
    // Upcoming text: ~100 words ahead of the current position
    final upcomingText = _words
        .sublist(
          _currentIndex + 1,
          (_currentIndex + 100).clamp(0, _words.length),
        )
        .join(' ');

    state$.add(
      ReadingState(
        pastText: pastText,
        focusText: focusText,
        upcomingText: upcomingText,
        currentWordIndex: _currentIndex,
        totalWords: _words.length,
        isPlaying: _scrollTimer != null,
        currentWpm: _wpm,
        highlightedWord: state$.value.highlightedWord,
      ),
    );
  }

  void dispose() {
    _scrollTimer?.cancel();
    // Do NOT close state$ — keep stream reusable
  }
}
