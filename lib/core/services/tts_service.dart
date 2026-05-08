import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/rxdart.dart';

/// Text-to-speech service for word pronunciation.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  final BehaviorSubject<bool> isPlaying$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> currentWord$ = BehaviorSubject.seeded(null);

  bool _initialized = false;
  bool _available = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        isPlaying$.add(false);
        currentWord$.add(null);
      });

      _tts.setCancelHandler(() {
        isPlaying$.add(false);
        currentWord$.add(null);
      });

      _tts.setErrorHandler((msg) {
        isPlaying$.add(false);
        currentWord$.add(null);
      });

      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  Future<bool> isAvailable() async {
    await _ensureInitialized();
    return _available;
  }

  Future<void> speak(String word) async {
    await _ensureInitialized();
    if (!_available) return;

    // Stop any current playback first
    await stop();

    isPlaying$.add(true);
    currentWord$.add(word);
    await _tts.speak(word);
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _tts.stop();
    isPlaying$.add(false);
    currentWord$.add(null);
  }

  void dispose() {
    stop();
    isPlaying$.close();
    currentWord$.close();
  }
}
