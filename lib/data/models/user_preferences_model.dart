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
  final int dailyGoalMinutes;
  final String textAlignment;
  final bool autoPlayOnOpen;
  final String readingBackground;
  final double readingMargin;
  final double brightnessOverlay;
  final double brightnessLevel;
  final String readingFontColor;
  final bool readingBold;
  final bool readingItalic;
  final bool readingUnderline;
  final String readingTheme;
  final String letterSpacing;
  final String userName;
  final List<String> celebratedMilestones;
  final String vocabSortField;
  final bool vocabSortAscending;
  final String librarySortField;
  final bool librarySortAscending;
  final bool hapticsEnabled;

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
    this.dailyGoalMinutes = 20,
    this.textAlignment = 'left',
    this.autoPlayOnOpen = false,
    this.readingBackground = 'default',
    this.readingMargin = 24,
    this.brightnessOverlay = 0,
    this.brightnessLevel = 0,
    this.readingFontColor = 'default',
    this.readingBold = false,
    this.readingItalic = false,
    this.readingUnderline = false,
    this.readingTheme = 'system',
    this.letterSpacing = 'normal',
    this.userName = '',
    this.celebratedMilestones = const [],
    this.vocabSortField = 'dateAdded',
    this.vocabSortAscending = false,
    this.librarySortField = 'lastRead',
    this.librarySortAscending = false,
    this.hapticsEnabled = true,
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
    'dailyGoalMinutes': dailyGoalMinutes,
    'textAlignment': textAlignment,
    'autoPlayOnOpen': autoPlayOnOpen,
    'readingBackground': readingBackground,
    'readingMargin': readingMargin,
    'brightnessOverlay': brightnessOverlay,
    'brightnessLevel': brightnessLevel,
    'readingFontColor': readingFontColor,
    'readingBold': readingBold,
    'readingItalic': readingItalic,
    'readingUnderline': readingUnderline,
    'readingTheme': readingTheme,
    'letterSpacing': letterSpacing,
    'userName': userName,
    'celebratedMilestones': celebratedMilestones,
    'vocabSortField': vocabSortField,
    'vocabSortAscending': vocabSortAscending,
    'librarySortField': librarySortField,
    'librarySortAscending': librarySortAscending,
    'hapticsEnabled': hapticsEnabled,
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
      dailyGoalMinutes: map['dailyGoalMinutes'] as int? ?? 20,
      textAlignment: map['textAlignment'] as String? ?? 'left',
      autoPlayOnOpen: map['autoPlayOnOpen'] as bool? ?? false,
      readingBackground: map['readingBackground'] as String? ?? 'default',
      readingMargin: (map['readingMargin'] as num?)?.toDouble() ?? 24,
      brightnessOverlay: (map['brightnessOverlay'] as num?)?.toDouble() ?? 0,
      brightnessLevel: (map['brightnessLevel'] as num?)?.toDouble() ?? 0,
      readingFontColor: map['readingFontColor'] as String? ?? 'default',
      readingBold: map['readingBold'] as bool? ?? false,
      readingItalic: map['readingItalic'] as bool? ?? false,
      readingUnderline: map['readingUnderline'] as bool? ?? false,
      readingTheme: map['readingTheme'] as String? ?? 'system',
      letterSpacing: map['letterSpacing'] as String? ?? 'normal',
      userName: map['userName'] as String? ?? '',
      celebratedMilestones:
          (map['celebratedMilestones'] as List<dynamic>?)?.cast<String>() ??
          const [],
      vocabSortField: map['vocabSortField'] as String? ?? 'dateAdded',
      vocabSortAscending: map['vocabSortAscending'] as bool? ?? false,
      librarySortField: map['librarySortField'] as String? ?? 'lastRead',
      librarySortAscending: map['librarySortAscending'] as bool? ?? false,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
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
    int? dailyGoalMinutes,
    String? textAlignment,
    bool? autoPlayOnOpen,
    String? readingBackground,
    double? readingMargin,
    double? brightnessOverlay,
    double? brightnessLevel,
    String? readingFontColor,
    bool? readingBold,
    bool? readingItalic,
    bool? readingUnderline,
    String? readingTheme,
    String? letterSpacing,
    String? userName,
    List<String>? celebratedMilestones,
    String? vocabSortField,
    bool? vocabSortAscending,
    String? librarySortField,
    bool? librarySortAscending,
    bool? hapticsEnabled,
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
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      textAlignment: textAlignment ?? this.textAlignment,
      autoPlayOnOpen: autoPlayOnOpen ?? this.autoPlayOnOpen,
      readingBackground: readingBackground ?? this.readingBackground,
      readingMargin: readingMargin ?? this.readingMargin,
      brightnessOverlay: brightnessOverlay ?? this.brightnessOverlay,
      brightnessLevel: brightnessLevel ?? this.brightnessLevel,
      readingFontColor: readingFontColor ?? this.readingFontColor,
      readingBold: readingBold ?? this.readingBold,
      readingItalic: readingItalic ?? this.readingItalic,
      readingUnderline: readingUnderline ?? this.readingUnderline,
      readingTheme: readingTheme ?? this.readingTheme,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      userName: userName ?? this.userName,
      celebratedMilestones: celebratedMilestones ?? this.celebratedMilestones,
      vocabSortField: vocabSortField ?? this.vocabSortField,
      vocabSortAscending: vocabSortAscending ?? this.vocabSortAscending,
      librarySortField: librarySortField ?? this.librarySortField,
      librarySortAscending: librarySortAscending ?? this.librarySortAscending,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
