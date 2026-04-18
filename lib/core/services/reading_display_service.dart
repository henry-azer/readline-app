import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ReadingPosition {
  final double offset;
  final int currentWordIndex;
  final String currentWord;
  final double progress;

  const ReadingPosition({
    required this.offset,
    required this.currentWordIndex,
    required this.currentWord,
    required this.progress,
  });
}

class ReadingDisplayService {
  Timer? _scrollTimer;
  final StreamController<ReadingPosition> _positionController = StreamController.broadcast();
  
  Stream<ReadingPosition> scrollText({
    required String content,
    required double wordsPerMinute,
    required double lineSpacing,
    VoidCallback? onWordChange,
  }) async* {
    final words = content.split(RegExp(r'\s+'));
    final totalWords = words.length;
    
    if (totalWords == 0) return;
    
    // Calculate timing
    final wordsPerSecond = wordsPerMinute / 60.0;
    final intervalPerWord = 1000.0 / wordsPerSecond; // milliseconds
    
    double currentOffset = 0.0;
    int currentWordIndex = 0;
    
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(
      Duration(milliseconds: intervalPerWord.round()),
      (timer) {
        if (currentWordIndex >= totalWords) {
          timer.cancel();
          _positionController.close();
          return;
        }
        
        final currentWord = words[currentWordIndex];
        final progress = currentWordIndex / totalWords;
        
        // Calculate scroll offset based on line spacing and word position
        currentOffset += _calculateScrollOffset(
          currentWord,
          lineSpacing,
          currentWordIndex,
        );
        
        final position = ReadingPosition(
          offset: currentOffset,
          currentWordIndex: currentWordIndex,
          currentWord: currentWord,
          progress: progress,
        );
        
        _positionController.add(position);
        onWordChange?.call();
        
        currentWordIndex++;
      },
    );
    
    yield* _positionController.stream;
  }

  void stopScrolling() {
    _scrollTimer?.cancel();
    _positionController.close();
  }

  void pauseScrolling() {
    _scrollTimer?.cancel();
  }

  void resumeScrolling({
    required String content,
    required double wordsPerMinute,
    required double lineSpacing,
    int startIndex = 0,
    VoidCallback? onWordChange,
  }) {
    final words = content.split(RegExp(r'\s+'));
    final totalWords = words.length;
    
    if (startIndex >= totalWords) return;
    
    final wordsPerSecond = wordsPerMinute / 60.0;
    final intervalPerWord = 1000.0 / wordsPerSecond;
    
    double currentOffset = _calculateOffsetForIndex(words, lineSpacing, startIndex);
    int currentWordIndex = startIndex;
    
    _scrollTimer = Timer.periodic(
      Duration(milliseconds: intervalPerWord.round()),
      (timer) {
        if (currentWordIndex >= totalWords) {
          timer.cancel();
          return;
        }
        
        final currentWord = words[currentWordIndex];
        final progress = currentWordIndex / totalWords;
        
        currentOffset += _calculateScrollOffset(
          currentWord,
          lineSpacing,
          currentWordIndex,
        );
        
        final position = ReadingPosition(
          offset: currentOffset,
          currentWordIndex: currentWordIndex,
          currentWord: currentWord,
          progress: progress,
        );
        
        _positionController.add(position);
        onWordChange?.call();
        
        currentWordIndex++;
      },
    );
  }

  double _calculateScrollOffset(String word, double lineSpacing, int wordIndex) {
    // Average character width estimation (can be refined based on actual font metrics)
    const double averageCharWidth = 8.0;
    const double lineHeight = 24.0;
    
    final wordWidth = word.length * averageCharWidth;
    final effectiveLineHeight = lineHeight * lineSpacing;
    
    // Simple estimation: assume ~10 words per line
    const int wordsPerLine = 10;
    final int lineNumber = wordIndex ~/ wordsPerLine;
    
    return lineNumber * effectiveLineHeight;
  }

  double _calculateOffsetForIndex(List<String> words, double lineSpacing, int index) {
    double offset = 0.0;
    const double lineHeight = 24.0;
    const int wordsPerLine = 10;
    
    for (int i = 0; i < index; i++) {
      offset += _calculateScrollOffset(words[i], lineSpacing, i);
    }
    
    return offset;
  }

  Stream<FocusWindowPosition> generateFocusWindow({
    required String content,
    required int windowSize,
    required double wordsPerMinute,
  }) async* {
    final words = content.split(RegExp(r'\s+'));
    final totalWords = words.length;
    
    if (totalWords == 0) return;
    
    final wordsPerSecond = wordsPerMinute / 60.0;
    final intervalPerWord = 1000.0 / wordsPerSecond;
    
    int currentCenterIndex = 0;
    
    while (currentCenterIndex < totalWords) {
      final start = math.max(0, currentCenterIndex - windowSize ~/ 2);
      final end = math.min(totalWords, currentCenterIndex + windowSize ~/ 2 + 1);
      
      final focusWords = words.sublist(start, end);
      final centerWord = words[currentCenterIndex];
      
      yield FocusWindowPosition(
        words: focusWords,
        centerWord: centerWord,
        centerIndex: currentCenterIndex - start,
        progress: currentCenterIndex / totalWords,
      );
      
      currentCenterIndex++;
      
      await Future.delayed(Duration(milliseconds: intervalPerWord.round()));
    }
  }

  ReadingMetrics calculateReadingMetrics({
    required String content,
    required Duration readingTime,
    required int wordsRead,
  }) {
    final totalWords = content.split(RegExp(r'\s+')).length;
    final wordsPerMinute = (wordsRead / readingTime.inMinutes) * 60.0;
    final comprehensionRate = wordsRead / totalWords;
    
    return ReadingMetrics(
      wordsPerMinute: wordsPerMinute,
      totalTime: readingTime,
      wordsRead: wordsRead,
      totalWords: totalWords,
      comprehensionRate: comprehensionRate,
      estimatedTimeRemaining: Duration(
        minutes: ((totalWords - wordsRead) / wordsPerMinute * 60).round(),
      ),
    );
  }
}

class FocusWindowPosition {
  final List<String> words;
  final String centerWord;
  final int centerIndex;
  final double progress;

  const FocusWindowPosition({
    required this.words,
    required this.centerWord,
    required this.centerIndex,
    required this.progress,
  });
}

class ReadingMetrics {
  final double wordsPerMinute;
  final Duration totalTime;
  final int wordsRead;
  final int totalWords;
  final double comprehensionRate;
  final Duration estimatedTimeRemaining;

  const ReadingMetrics({
    required this.wordsPerMinute,
    required this.totalTime,
    required this.wordsRead,
    required this.totalWords,
    required this.comprehensionRate,
    required this.estimatedTimeRemaining,
  });

  @override
  String toString() {
    return 'ReadingMetrics(WPM: ${wordsPerMinute.toStringAsFixed(1)}, '
           'Time: ${totalTime.inMinutes}:${(totalTime.inSeconds % 60).toString().padLeft(2, '0')}, '
           'Progress: ${(comprehensionRate * 100).toStringAsFixed(1)}%)';
  }
}
