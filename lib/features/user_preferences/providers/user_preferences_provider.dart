import 'package:flutter/material.dart';
import '../../../data/models/user_preferences_model.dart';
import '../../../domain/repositories/user_preferences_repository.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final UserPreferencesRepository _repository;

  UserPreferencesProvider(this._repository);

  UserPreferencesModel _preferences = UserPreferencesModel.defaultSettings;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserPreferencesModel get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Convenience getters
  double get readingSpeed => _preferences.readingSpeed;
  double get lineSpacing => _preferences.lineSpacing;
  int get fontSize => _preferences.fontSize;
  ThemeMode get themeMode => _preferences.themeMode;
  int get focusWindowSize => _preferences.focusWindowSize;
  String get fontFamily => _preferences.fontFamily;
  bool get enableVocabularyCollection => _preferences.enableVocabularyCollection;
  bool get enableAnalytics => _preferences.enableAnalytics;

  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final preferences = await _repository.getPreferences();
      _preferences = preferences.toModel();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReadingSpeed(double speed) async {
    try {
      if (speed < 50 || speed > 500) {
        throw Exception('Reading speed must be between 50 and 500 WPM');
      }

      await _repository.updateReadingSpeed(speed);
      _preferences = _preferences.copyWith(readingSpeed: speed);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update reading speed: $e';
      notifyListeners();
    }
  }

  Future<void> updateLineSpacing(double spacing) async {
    try {
      if (spacing < 1.0 || spacing > 3.0) {
        throw Exception('Line spacing must be between 1.0 and 3.0');
      }

      await _repository.updateLineSpacing(spacing);
      _preferences = _preferences.copyWith(lineSpacing: spacing);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update line spacing: $e';
      notifyListeners();
    }
  }

  Future<void> updateFontSize(int size) async {
    try {
      if (size < 12 || size > 24) {
        throw Exception('Font size must be between 12 and 24');
      }

      await _repository.updateFontSize(size);
      _preferences = _preferences.copyWith(fontSize: size);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update font size: $e';
      notifyListeners();
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    try {
      await _repository.updateThemeMode(mode);
      _preferences = _preferences.copyWith(themeMode: mode);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update theme mode: $e';
      notifyListeners();
    }
  }

  Future<void> updateFocusWindowSize(int size) async {
    try {
      if (size < 1 || size > 10) {
        throw Exception('Focus window size must be between 1 and 10');
      }

      await _repository.updateFocusWindowSize(size);
      _preferences = _preferences.copyWith(focusWindowSize: size);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update focus window size: $e';
      notifyListeners();
    }
  }

  Future<void> updateFontFamily(String fontFamily) async {
    try {
      if (fontFamily.isEmpty) {
        throw Exception('Font family cannot be empty');
      }

      await _repository.updateFontFamily(fontFamily);
      _preferences = _preferences.copyWith(fontFamily: fontFamily);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update font family: $e';
      notifyListeners();
    }
  }

  Future<void> updateVocabularyCollection(bool enabled) async {
    try {
      await _repository.updateVocabularyCollection(enabled);
      _preferences = _preferences.copyWith(enableVocabularyCollection: enabled);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update vocabulary collection: $e';
      notifyListeners();
    }
  }

  Future<void> updateAnalytics(bool enabled) async {
    try {
      await _repository.updateAnalytics(enabled);
      _preferences = _preferences.copyWith(enableAnalytics: enabled);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update analytics setting: $e';
      notifyListeners();
    }
  }

  Future<void> updateMultiplePreferences({
    double? readingSpeed,
    double? lineSpacing,
    int? fontSize,
    ThemeMode? themeMode,
    int? focusWindowSize,
    String? fontFamily,
    bool? enableVocabularyCollection,
    bool? enableAnalytics,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update each preference individually
      if (readingSpeed != null) await updateReadingSpeed(readingSpeed);
      if (lineSpacing != null) await updateLineSpacing(lineSpacing);
      if (fontSize != null) await updateFontSize(fontSize);
      if (themeMode != null) await updateThemeMode(themeMode);
      if (focusWindowSize != null) await updateFocusWindowSize(focusWindowSize);
      if (fontFamily != null) await updateFontFamily(fontFamily);
      if (enableVocabularyCollection != null) await updateVocabularyCollection(enableVocabularyCollection);
      if (enableAnalytics != null) await updateAnalytics(enableAnalytics);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.resetToDefaults();
      _preferences = UserPreferencesModel.defaultSettings;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reset preferences: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Preset configurations
  Future<void> applyBeginnerPreset() async {
    await updateMultiplePreferences(
      readingSpeed: 150,
      lineSpacing: 2.0,
      fontSize: 18,
      focusWindowSize: 5,
    );
  }

  Future<void> applyIntermediatePreset() async {
    await updateMultiplePreferences(
      readingSpeed: 200,
      lineSpacing: 1.5,
      fontSize: 16,
      focusWindowSize: 3,
    );
  }

  Future<void> applyAdvancedPreset() async {
    await updateMultiplePreferences(
      readingSpeed: 300,
      lineSpacing: 1.2,
      fontSize: 14,
      focusWindowSize: 2,
    );
  }

  // Validation helpers
  bool isValidReadingSpeed(double speed) => speed >= 50 && speed <= 500;
  bool isValidLineSpacing(double spacing) => spacing >= 1.0 && spacing <= 3.0;
  bool isValidFontSize(int size) => size >= 12 && size <= 24;
  bool isValidFocusWindowSize(int size) => size >= 1 && size <= 10;

  // Export/Import preferences
  Map<String, dynamic> exportPreferences() {
    return _preferences.toMap();
  }

  Future<void> importPreferences(Map<String, dynamic> data) async {
    try {
      final model = UserPreferencesModel.fromMap(data);
      await _repository.savePreferences(model);
      _preferences = model;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to import preferences: $e';
      notifyListeners();
    }
  }
}
