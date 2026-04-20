class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final List<bool> weeklyActivity;
  final int totalReadingDays;
  final String? milestoneLabel;

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
  });

  Map<String, dynamic> toMap() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastReadDate': lastReadDate?.millisecondsSinceEpoch,
    'weeklyActivity': weeklyActivity,
    'totalReadingDays': totalReadingDays,
    'milestoneLabel': milestoneLabel,
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
    );
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    List<bool>? weeklyActivity,
    int? totalReadingDays,
    Object? milestoneLabel = _sentinel,
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
    );
  }
}

const Object _sentinel = Object();
