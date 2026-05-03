enum CelebrationType { streakMilestone, dailyTarget, wordsMilestone }

enum CelebrationTier { bronze, silver, gold, platinum, diamond }

class CelebrationData {
  final CelebrationType type;
  final CelebrationTier tier;
  final int streakCount;
  final double minutesRead;
  final int wordsCount;
  final String messageKey;
  final String titleKey;

  const CelebrationData({
    required this.type,
    required this.tier,
    this.streakCount = 0,
    this.minutesRead = 0,
    this.wordsCount = 0,
    required this.messageKey,
    required this.titleKey,
  });

  static CelebrationTier tierForStreak(int streak) {
    // Aligned with milestone schedule: 1, 3, 7, 14, 21+
    if (streak >= 21) return CelebrationTier.diamond;
    if (streak >= 14) return CelebrationTier.platinum;
    if (streak >= 7) return CelebrationTier.gold;
    if (streak >= 3) return CelebrationTier.silver;
    return CelebrationTier.bronze;
  }

  static CelebrationTier tierForWords(int words) {
    if (words >= 100000) return CelebrationTier.diamond;
    if (words >= 50000) return CelebrationTier.platinum;
    if (words >= 10000) return CelebrationTier.gold;
    if (words >= 5000) return CelebrationTier.silver;
    return CelebrationTier.bronze;
  }
}
