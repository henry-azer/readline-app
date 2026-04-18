import '../entities/user_preferences.dart';

abstract class UserPreferencesRepository {
  /// Get current user preferences
  Future<UserPreferences> getPreferences();
  
  /// Save all user preferences
  Future<void> savePreferences(UserPreferences preferences);
  
  /// Update reading speed
  Future<void> updateReadingSpeed(double speed);
  
  /// Update line spacing
  Future<void> updateLineSpacing(double spacing);
  
  /// Update font size
  Future<void> updateFontSize(int fontSize);
  
  /// Update theme mode
  Future<void> updateThemeMode(ThemeMode themeMode);
  
  /// Update focus window size
  Future<void> updateFocusWindowSize(int size);
  
  /// Update font family
  Future<void> updateFontFamily(String fontFamily);
  
  /// Update vocabulary collection setting
  Future<void> updateVocabularyCollection(bool enabled);
  
  /// Update analytics setting
  Future<void> updateAnalytics(bool enabled);
  
  /// Reset all preferences to defaults
  Future<void> resetToDefaults();
  
  /// Export preferences as map
  Future<Map<String, dynamic>> exportPreferences();
  
  /// Import preferences from map
  Future<void> importPreferences(Map<String, dynamic> data);
  
  /// Get preference change history
  Future<List<PreferenceChange>> getPreferenceHistory({int limit = 50});
  
  /// Validate preference values
  Future<PreferenceValidation> validatePreferences(UserPreferences preferences);
}

class PreferenceChange {
  final String preferenceKey;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;
  final String? reason;

  const PreferenceChange({
    required this.preferenceKey,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
    this.reason,
  });

  @override
  String toString() {
    return 'PreferenceChange(key: $preferenceKey, from: $oldValue, to: $newValue, at: $timestamp)';
  }
}

class PreferenceValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const PreferenceValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  const PreferenceValidation.valid()
      : isValid = true,
        errors = const [],
        warnings = const [];

  const PreferenceValidation.invalid(List<String> errors, [List<String>? warnings])
      : isValid = false,
        errors = errors,
        warnings = warnings ?? [];

  PreferenceValidation.withWarnings(List<String> warnings)
      : isValid = true,
        errors = const [],
        warnings = warnings;

  @override
  String toString() {
    return 'PreferenceValidation(valid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
  }
}
