import '../datasources/user_preferences_local_datasource.dart';
import '../models/user_preferences_model.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesLocalDataSource localDataSource;

  UserPreferencesRepositoryImpl(this.localDataSource);

  @override
  Future<UserPreferences> getPreferences() async {
    try {
      final model = await localDataSource.getPreferences();
      return UserPreferences.fromModel(model);
    } catch (e) {
      throw UserPreferencesException('Failed to get preferences: $e');
    }
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      final model = preferences.toModel();
      await localDataSource.savePreferences(model);
    } catch (e) {
      throw UserPreferencesException('Failed to save preferences: $e');
    }
  }

  @override
  Future<void> updateReadingSpeed(double speed) async {
    try {
      await localDataSource.updateReadingSpeed(speed);
    } catch (e) {
      throw UserPreferencesException('Failed to update reading speed: $e');
    }
  }

  @override
  Future<void> updateLineSpacing(double spacing) async {
    try {
      await localDataSource.updateLineSpacing(spacing);
    } catch (e) {
      throw UserPreferencesException('Failed to update line spacing: $e');
    }
  }

  @override
  Future<void> updateFontSize(int fontSize) async {
    try {
      await localDataSource.updateFontSize(fontSize);
    } catch (e) {
      throw UserPreferencesException('Failed to update font size: $e');
    }
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      await localDataSource.updateThemeMode(themeMode.toString());
    } catch (e) {
      throw UserPreferencesException('Failed to update theme mode: $e');
    }
  }

  @override
  Future<void> updateFocusWindowSize(int size) async {
    try {
      await localDataSource.updateFocusWindowSize(size);
    } catch (e) {
      throw UserPreferencesException('Failed to update focus window size: $e');
    }
  }

  @override
  Future<void> updateFontFamily(String fontFamily) async {
    try {
      await localDataSource.updateFontFamily(fontFamily);
    } catch (e) {
      throw UserPreferencesException('Failed to update font family: $e');
    }
  }

  @override
  Future<void> updateVocabularyCollection(bool enabled) async {
    try {
      await localDataSource.updateVocabularyCollection(enabled);
    } catch (e) {
      throw UserPreferencesException('Failed to update vocabulary collection: $e');
    }
  }

  @override
  Future<void> updateAnalytics(bool enabled) async {
    try {
      await localDataSource.updateAnalytics(enabled);
    } catch (e) {
      throw UserPreferencesException('Failed to update analytics setting: $e');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await localDataSource.savePreferences(UserPreferencesModel.defaultSettings);
    } catch (e) {
      throw UserPreferencesException('Failed to reset to defaults: $e');
    }
  }
}

class UserPreferencesException implements Exception {
  final String message;
  UserPreferencesException(this.message);
  
  @override
  String toString() => 'UserPreferencesException: $message';
}
