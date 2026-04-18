import 'package:flutter/material.dart';
import '../../../core/services/reading_display_service.dart';
import '../../../domain/repositories/user_preferences_repository.dart';

enum ReadingState {
  initial,
  ready,
  reading,
  paused,
  completed,
  error,
}

class ReadingDisplayProvider extends ChangeNotifier {
  final ReadingDisplayService _displayService;
  final UserPreferencesRepository _preferencesRepository;

  ReadingDisplayProvider(this._displayService, this._preferencesRepository);

  ReadingState _state = ReadingState.initial;
  String _currentContent = '';
  double _currentSpeed = 200.0;
  double _lineSpacing = 1.5;
  int _fontSize = 16;
  int _focusWindowSize = 3;
  bool _isPlaying = false;
  String? _errorMessage;
  ReadingPosition? _currentPosition;
  ReadingMetrics? _currentMetrics;
  Duration _totalReadingTime = Duration.zero;
  int _wordsRead = 0;
  DateTime? _sessionStartTime;
  DateTime? _sessionEndTime;

  // Stream subscription for reading position
  StreamSubscription<ReadingPosition>? _positionSubscription;

  // Getters
  ReadingState get state => _state;
  String get currentContent => _currentContent;
  double get currentSpeed => _currentSpeed;
  double get lineSpacing => _lineSpacing;
  int get fontSize => _fontSize;
  int get focusWindowSize => _focusWindowSize;
  bool get isPlaying => _isPlaying;
  String? get errorMessage => _errorMessage;
  ReadingPosition? get currentPosition => _currentPosition;
  ReadingMetrics? get currentMetrics => _currentMetrics;
  Duration get totalReadingTime => _totalReadingTime;
  int get wordsRead => _wordsRead;
  double get progress => _currentPosition?.progress ?? 0.0;
  bool get hasContent => _currentContent.isNotEmpty;
  bool get isReading => _state == ReadingState.reading;
  bool get isPaused => _state == ReadingState.paused;

  Future<void> loadContent(String content) async {
    try {
      _currentContent = content;
      _wordsRead = 0;
      _currentPosition = null;
      _currentMetrics = null;
      _totalReadingTime = Duration.zero;
      _setState(ReadingState.ready);
    } catch (e) {
      _errorMessage = 'Failed to load content: $e';
      _setState(ReadingState.error);
    }
  }

  Future<void> startReading() async {
    if (_currentContent.isEmpty) {
      _errorMessage = 'No content to read';
      _setState(ReadingState.error);
      return;
    }

    try {
      _isPlaying = true;
      _sessionStartTime = DateTime.now();
      _setState(ReadingState.reading);

      _positionSubscription = _displayService.scrollText(
        content: _currentContent,
        wordsPerMinute: _currentSpeed,
        lineSpacing: _lineSpacing,
        onWordChange: _updateWordCount,
      ).listen(
        (position) {
          _currentPosition = position;
          _updateMetrics();
          notifyListeners();

          if (position.progress >= 1.0) {
            completeReading();
          }
        },
        onError: (error) {
          _errorMessage = 'Reading error: $error';
          _setState(ReadingState.error);
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to start reading: $e';
      _setState(ReadingState.error);
    }
  }

  void pauseReading() {
    try {
      _isPlaying = false;
      _displayService.pauseScrolling();
      _positionSubscription?.pause();
      _setState(ReadingState.paused);
    } catch (e) {
      _errorMessage = 'Failed to pause reading: $e';
      notifyListeners();
    }
  }

  void resumeReading() {
    if (_currentPosition == null) return;

    try {
      _isPlaying = true;
      _setState(ReadingState.reading);

      _displayService.resumeScrolling(
        content: _currentContent,
        wordsPerMinute: _currentSpeed,
        lineSpacing: _lineSpacing,
        startIndex: _currentPosition!.currentWordIndex,
        onWordChange: _updateWordCount,
      );
    } catch (e) {
      _errorMessage = 'Failed to resume reading: $e';
      _setState(ReadingState.error);
    }
  }

  void stopReading() {
    try {
      _isPlaying = false;
      _displayService.stopScrolling();
      _positionSubscription?.cancel();
      _positionSubscription = null;
      _setState(ReadingState.ready);
    } catch (e) {
      _errorMessage = 'Failed to stop reading: $e';
      notifyListeners();
    }
  }

  void completeReading() {
    _isPlaying = false;
    _sessionEndTime = DateTime.now();
    _displayService.stopScrolling();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _setState(ReadingState.completed);
    
    // Final metrics update
    _updateMetrics();
  }

  Future<void> adjustSpeed(double newSpeed) async {
    try {
      _currentSpeed = newSpeed;
      await _preferencesRepository.updateReadingSpeed(newSpeed);
      
      // Restart reading with new speed if currently reading
      if (isReading) {
        stopReading();
        startReading();
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to adjust speed: $e';
      notifyListeners();
    }
  }

  Future<void> adjustLineSpacing(double newSpacing) async {
    try {
      _lineSpacing = newSpacing;
      await _preferencesRepository.updateLineSpacing(newSpacing);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to adjust line spacing: $e';
      notifyListeners();
    }
  }

  Future<void> adjustFontSize(int newSize) async {
    try {
      _fontSize = newSize;
      await _preferencesRepository.updateFontSize(newSize);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to adjust font size: $e';
      notifyListeners();
    }
  }

  Future<void> adjustFocusWindowSize(int newSize) async {
    try {
      _focusWindowSize = newSize;
      await _preferencesRepository.updateFocusWindowSize(newSize);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to adjust focus window: $e';
      notifyListeners();
    }
  }

  void jumpToPosition(double progress) {
    if (_currentContent.isEmpty) return;

    final words = _currentContent.split(RegExp(r'\s+'));
    final targetIndex = (words.length * progress).round();
    
    if (isReading) {
      stopReading();
    }
    
    _currentPosition = ReadingPosition(
      offset: 0.0,
      currentWordIndex: targetIndex,
      currentWord: words[targetIndex.clamp(0, words.length - 1)],
      progress: progress,
    );
    
    notifyListeners();
  }

  void _updateWordCount() {
    _wordsRead++;
    notifyListeners();
  }

  void _updateMetrics() {
    if (_sessionStartTime != null) {
      final currentTime = DateTime.now();
      final sessionTime = currentTime.difference(_sessionStartTime!);
      _totalReadingTime = sessionTime;
      
      _currentMetrics = _displayService.calculateReadingMetrics(
        content: _currentContent,
        readingTime: _totalReadingTime,
        wordsRead: _wordsRead,
      );
    }
  }

  void _setState(ReadingState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    stopReading();
    _currentContent = '';
    _wordsRead = 0;
    _currentPosition = null;
    _currentMetrics = null;
    _totalReadingTime = Duration.zero;
    _sessionStartTime = null;
    _sessionEndTime = null;
    _setState(ReadingState.initial);
  }

  // Reading statistics
  double get averageSpeed => _currentMetrics?.wordsPerMinute ?? _currentSpeed;
  Duration get estimatedTimeRemaining => _currentMetrics?.estimatedTimeRemaining ?? Duration.zero;
  double get comprehensionRate => _currentMetrics?.comprehensionRate ?? 0.0;

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
