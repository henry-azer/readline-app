class UserPreferencesModel {
  final int readingSpeedWpm;
  final double lineSpacing;
  final int fontSize;
  final int focusWindowLines;
  final String themeMode;
  final String fontFamily;
  final bool enableVocabCollection;
  final bool enableAnalytics;
  final String readingLevel;
  final bool onboardingCompleted;
  final String languageCode;

  const UserPreferencesModel({
    this.readingSpeedWpm = 200,
    this.lineSpacing = 1.5,
    this.fontSize = 18,
    this.focusWindowLines = 3,
    this.themeMode = 'system',
    this.fontFamily = 'newsreader',
    this.enableVocabCollection = true,
    this.enableAnalytics = true,
    this.readingLevel = 'intermediate',
    this.onboardingCompleted = false,
    this.languageCode = 'en',
  });

  Map<String, dynamic> toMap() => {
    'readingSpeedWpm': readingSpeedWpm,
    'lineSpacing': lineSpacing,
    'fontSize': fontSize,
    'focusWindowLines': focusWindowLines,
    'themeMode': themeMode,
    'fontFamily': fontFamily,
    'enableVocabCollection': enableVocabCollection,
    'enableAnalytics': enableAnalytics,
    'readingLevel': readingLevel,
    'onboardingCompleted': onboardingCompleted,
    'languageCode': languageCode,
  };

  factory UserPreferencesModel.fromMap(Map<dynamic, dynamic> map) {
    return UserPreferencesModel(
      readingSpeedWpm: map['readingSpeedWpm'] as int? ?? 200,
      lineSpacing: (map['lineSpacing'] as num?)?.toDouble() ?? 1.5,
      fontSize: map['fontSize'] as int? ?? 18,
      focusWindowLines: map['focusWindowLines'] as int? ?? 3,
      themeMode: map['themeMode'] as String? ?? 'system',
      fontFamily: map['fontFamily'] as String? ?? 'newsreader',
      enableVocabCollection: map['enableVocabCollection'] as bool? ?? true,
      enableAnalytics: map['enableAnalytics'] as bool? ?? true,
      readingLevel: map['readingLevel'] as String? ?? 'intermediate',
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      languageCode: map['languageCode'] as String? ?? 'en',
    );
  }

  UserPreferencesModel copyWith({
    int? readingSpeedWpm,
    double? lineSpacing,
    int? fontSize,
    int? focusWindowLines,
    String? themeMode,
    String? fontFamily,
    bool? enableVocabCollection,
    bool? enableAnalytics,
    String? readingLevel,
    bool? onboardingCompleted,
    String? languageCode,
  }) {
    return UserPreferencesModel(
      readingSpeedWpm: readingSpeedWpm ?? this.readingSpeedWpm,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      fontSize: fontSize ?? this.fontSize,
      focusWindowLines: focusWindowLines ?? this.focusWindowLines,
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      enableVocabCollection:
          enableVocabCollection ?? this.enableVocabCollection,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      readingLevel: readingLevel ?? this.readingLevel,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
