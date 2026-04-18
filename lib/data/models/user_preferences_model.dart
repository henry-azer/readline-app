import 'package:flutter/material.dart';

class UserPreferencesModel {
  final int id;
  final double readingSpeed;
  final double lineSpacing;
  final int fontSize;
  final ThemeMode themeMode;
  final int focusWindowSize;
  final String fontFamily;
  final bool enableVocabularyCollection;
  final bool enableAnalytics;

  const UserPreferencesModel({
    this.id = 1,
    this.readingSpeed = 200.0,
    this.lineSpacing = 1.5,
    this.fontSize = 16,
    this.themeMode = ThemeMode.system,
    this.focusWindowSize = 3,
    this.fontFamily = 'Inter',
    this.enableVocabularyCollection = true,
    this.enableAnalytics = true,
  });

  static const UserPreferencesModel defaultSettings = UserPreferencesModel();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reading_speed': readingSpeed,
      'line_spacing': lineSpacing,
      'font_size': fontSize,
      'theme_mode': themeMode.toString(),
      'focus_window_size': focusWindowSize,
      'font_family': fontFamily,
      'enable_vocabulary_collection': enableVocabularyCollection ? 1 : 0,
      'enable_analytics': enableAnalytics ? 1 : 0,
    };
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      id: map['id'] as int,
      readingSpeed: (map['reading_speed'] as num).toDouble(),
      lineSpacing: (map['line_spacing'] as num).toDouble(),
      fontSize: map['font_size'] as int,
      themeMode: _parseThemeMode(map['theme_mode'] as String),
      focusWindowSize: map['focus_window_size'] as int,
      fontFamily: map['font_family'] as String? ?? 'Inter',
      enableVocabularyCollection: (map['enable_vocabulary_collection'] as int) == 1,
      enableAnalytics: (map['enable_analytics'] as int) == 1,
    );
  }

  static ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  UserPreferencesModel copyWith({
    int? id,
    double? readingSpeed,
    double? lineSpacing,
    int? fontSize,
    ThemeMode? themeMode,
    int? focusWindowSize,
    String? fontFamily,
    bool? enableVocabularyCollection,
    bool? enableAnalytics,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      readingSpeed: readingSpeed ?? this.readingSpeed,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
      focusWindowSize: focusWindowSize ?? this.focusWindowSize,
      fontFamily: fontFamily ?? this.fontFamily,
      enableVocabularyCollection: enableVocabularyCollection ?? this.enableVocabularyCollection,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferencesModel &&
        other.id == id &&
        other.readingSpeed == readingSpeed &&
        other.lineSpacing == lineSpacing &&
        other.fontSize == fontSize &&
        other.themeMode == themeMode &&
        other.focusWindowSize == focusWindowSize &&
        other.fontFamily == fontFamily &&
        other.enableVocabularyCollection == enableVocabularyCollection &&
        other.enableAnalytics == enableAnalytics;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        readingSpeed.hashCode ^
        lineSpacing.hashCode ^
        fontSize.hashCode ^
        themeMode.hashCode ^
        focusWindowSize.hashCode ^
        fontFamily.hashCode ^
        enableVocabularyCollection.hashCode ^
        enableAnalytics.hashCode;
  }
}
