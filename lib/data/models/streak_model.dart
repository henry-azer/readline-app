class StreakHistoryEntry {
  final DateTime startDate;
  final DateTime endDate;
  final int length;

  const StreakHistoryEntry({
    required this.startDate,
    required this.endDate,
    required this.length,
  });

  Map<String, dynamic> toMap() => {
    'startDate': startDate.millisecondsSinceEpoch,
    'endDate': endDate.millisecondsSinceEpoch,
    'length': length,
  };

  factory StreakHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return StreakHistoryEntry(
      startDate: DateTime.fromMillisecondsSinceEpoch(
        map['startDate'] as int? ?? 0,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int? ?? 0),
      length: map['length'] as int? ?? 0,
    );
  }
}

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final List<bool> weeklyActivity;
  final int totalReadingDays;
  final String? milestoneLabel;
  final List<StreakHistoryEntry> streakHistory;
  final bool streakJustBroke;

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
    this.weeklyActivity = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    this.totalReadingDays = 0,
    this.milestoneLabel,
    this.streakHistory = const [],
    this.streakJustBroke = false,
  });

  Map<String, dynamic> toMap() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastReadDate': lastReadDate?.millisecondsSinceEpoch,
    'weeklyActivity': weeklyActivity,
    'totalReadingDays': totalReadingDays,
    'milestoneLabel': milestoneLabel,
    'streakHistory': streakHistory.map((e) => e.toMap()).toList(),
    'streakJustBroke': streakJustBroke,
  };

  factory StreakModel.fromMap(Map<dynamic, dynamic> map) {
    return StreakModel(
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastReadDate: map['lastReadDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReadDate'] as int)
          : null,
      weeklyActivity:
          (map['weeklyActivity'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          const [false, false, false, false, false, false, false],
      totalReadingDays: map['totalReadingDays'] as int? ?? 0,
      milestoneLabel: map['milestoneLabel'] as String?,
      streakHistory:
          (map['streakHistory'] as List<dynamic>?)
              ?.map(
                (e) => StreakHistoryEntry.fromMap(e as Map<dynamic, dynamic>),
              )
              .toList() ??
          const [],
      streakJustBroke: map['streakJustBroke'] as bool? ?? false,
    );
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    List<bool>? weeklyActivity,
    int? totalReadingDays,
    Object? milestoneLabel = _sentinel,
    List<StreakHistoryEntry>? streakHistory,
    bool? streakJustBroke,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      totalReadingDays: totalReadingDays ?? this.totalReadingDays,
      milestoneLabel: milestoneLabel == _sentinel
          ? this.milestoneLabel
          : milestoneLabel as String?,
      streakHistory: streakHistory ?? this.streakHistory,
      streakJustBroke: streakJustBroke ?? this.streakJustBroke,
    );
  }
}

const Object _sentinel = Object();
