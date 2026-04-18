import 'package:flutter/material.dart';
import '../../data/models/user_preferences_model.dart';

class UserPreferences {
  final int id;
  final double readingSpeed;
  final double lineSpacing;
  final int fontSize;
  final ThemeMode themeMode;
  final int focusWindowSize;
  final String fontFamily;
  final bool enableVocabularyCollection;
  final bool enableAnalytics;

  const UserPreferences({
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

  // Factory constructor to create from model
  factory UserPreferences.fromModel(UserPreferencesModel model) {
    return UserPreferences(
      id: model.id,
      readingSpeed: model.readingSpeed,
      lineSpacing: model.lineSpacing,
      fontSize: model.fontSize,
      themeMode: model.themeMode,
      focusWindowSize: model.focusWindowSize,
      fontFamily: model.fontFamily,
      enableVocabularyCollection: model.enableVocabularyCollection,
      enableAnalytics: model.enableAnalytics,
    );
  }

  // Convert to model for data layer
  UserPreferencesModel toModel() {
    return UserPreferencesModel(
      id: id,
      readingSpeed: readingSpeed,
      lineSpacing: lineSpacing,
      fontSize: fontSize,
      themeMode: themeMode,
      focusWindowSize: focusWindowSize,
      fontFamily: fontFamily,
      enableVocabularyCollection: enableVocabularyCollection,
      enableAnalytics: enableAnalytics,
    );
  }

  // Reading level based on speed
  ReadingLevel get readingLevel {
    if (readingSpeed < 150) return ReadingLevel.beginner;
    if (readingSpeed < 250) return ReadingLevel.intermediate;
    if (readingSpeed < 350) return ReadingLevel.advanced;
    return ReadingLevel.expert;
  }

  // Validation methods
  bool get isValidReadingSpeed => readingSpeed >= 50 && readingSpeed <= 500;
  bool get isValidLineSpacing => lineSpacing >= 1.0 && lineSpacing <= 3.0;
  bool get isValidFontSize => fontSize >= 12 && fontSize <= 24;
  bool get isValidFocusWindowSize => focusWindowSize >= 1 && focusWindowSize <= 10;

  // Copy with validation
  UserPreferences copyWithValidated({
    double? readingSpeed,
    double? lineSpacing,
    int? fontSize,
    ThemeMode? themeMode,
    int? focusWindowSize,
    String? fontFamily,
    bool? enableVocabularyCollection,
    bool? enableAnalytics,
  }) {
    return UserPreferences(
      id: id,
      readingSpeed: readingSpeed?.clamp(50.0, 500.0) ?? this.readingSpeed,
      lineSpacing: lineSpacing?.clamp(1.0, 3.0) ?? this.lineSpacing,
      fontSize: fontSize?.clamp(12, 24) ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
      focusWindowSize: focusWindowSize?.clamp(1, 10) ?? this.focusWindowSize,
      fontFamily: fontFamily?.isNotEmpty == true ? fontFamily! : this.fontFamily,
      enableVocabularyCollection: enableVocabularyCollection ?? this.enableVocabularyCollection,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
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

  @override
  String toString() {
    return 'UserPreferences(speed: $readingSpeed WPM, spacing: ${lineSpacing}x, font: ${fontSize}pt)';
  }
}

enum ReadingLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension ReadingLevelExtension on ReadingLevel {
  String get displayName {
    switch (this) {
      case ReadingLevel.beginner:
        return 'Beginner';
      case ReadingLevel.intermediate:
        return 'Intermediate';
      case ReadingLevel.advanced:
        return 'Advanced';
      case ReadingLevel.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case ReadingLevel.beginner:
        return 'Slow and steady reading (50-150 WPM)';
      case ReadingLevel.intermediate:
        return 'Comfortable reading speed (150-250 WPM)';
      case ReadingLevel.advanced:
        return 'Fast reading (250-350 WPM)';
      case ReadingLevel.expert:
        return 'Speed reading (350+ WPM)';
    }
  }

  Color get color {
    switch (this) {
      case ReadingLevel.beginner:
        return Colors.green;
      case ReadingLevel.intermediate:
        return Colors.blue;
      case ReadingLevel.advanced:
        return Colors.orange;
      case ReadingLevel.expert:
        return Colors.red;
    }
  }
}
