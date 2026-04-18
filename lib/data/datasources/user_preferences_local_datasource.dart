import 'package:sqflite/sqflite.dart';
import '../models/user_preferences_model.dart';

abstract class UserPreferencesLocalDataSource {
  Future<UserPreferencesModel> getPreferences();
  Future<void> savePreferences(UserPreferencesModel preferences);
  Future<void> updateReadingSpeed(double speed);
  Future<void> updateLineSpacing(double spacing);
  Future<void> updateFontSize(int fontSize);
  Future<void> updateThemeMode(String themeMode);
  Future<void> updateFocusWindowSize(int size);
  Future<void> updateFontFamily(String fontFamily);
  Future<void> updateVocabularyCollection(bool enabled);
  Future<void> updateAnalytics(bool enabled);
}

class UserPreferencesLocalDataSourceImpl implements UserPreferencesLocalDataSource {
  final Database database;

  UserPreferencesLocalDataSourceImpl(this.database);

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'user_preferences',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return UserPreferencesModel.fromMap(maps.first);
      }

      // Return default preferences if none exist
      return UserPreferencesModel.defaultSettings;
    } catch (e) {
      throw Exception('Failed to retrieve user preferences: $e');
    }
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    try {
      await database.insert(
        'user_preferences',
        preferences.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  @override
  Future<void> updateReadingSpeed(double speed) async {
    try {
      await database.update(
        'user_preferences',
        {'reading_speed': speed},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update reading speed: $e');
    }
  }

  @override
  Future<void> updateLineSpacing(double spacing) async {
    try {
      await database.update(
        'user_preferences',
        {'line_spacing': spacing},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update line spacing: $e');
    }
  }

  @override
  Future<void> updateFontSize(int fontSize) async {
    try {
      await database.update(
        'user_preferences',
        {'font_size': fontSize},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update font size: $e');
    }
  }

  @override
  Future<void> updateThemeMode(String themeMode) async {
    try {
      await database.update(
        'user_preferences',
        {'theme_mode': themeMode},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update theme mode: $e');
    }
  }

  @override
  Future<void> updateFocusWindowSize(int size) async {
    try {
      await database.update(
        'user_preferences',
        {'focus_window_size': size},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update focus window size: $e');
    }
  }

  @override
  Future<void> updateFontFamily(String fontFamily) async {
    try {
      await database.update(
        'user_preferences',
        {'font_family': fontFamily},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update font family: $e');
    }
  }

  @override
  Future<void> updateVocabularyCollection(bool enabled) async {
    try {
      await database.update(
        'user_preferences',
        {'enable_vocabulary_collection': enabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update vocabulary collection: $e');
    }
  }

  @override
  Future<void> updateAnalytics(bool enabled) async {
    try {
      await database.update(
        'user_preferences',
        {'enable_analytics': enabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('Failed to update analytics setting: $e');
    }
  }

  Future<void> initializeDefaultPreferences() async {
    try {
      final existing = await getPreferences();
      
      // Only insert if no preferences exist
      if (existing.id == 1 && existing.readingSpeed == 200.0) {
        await savePreferences(UserPreferencesModel.defaultSettings);
      }
    } catch (e) {
      // If table doesn't exist or other error, try to save defaults
      await savePreferences(UserPreferencesModel.defaultSettings);
    }
  }
}
