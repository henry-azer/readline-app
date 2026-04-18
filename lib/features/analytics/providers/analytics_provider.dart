import 'package:flutter/material.dart';
import '../../../domain/repositories/reading_session_repository.dart';
import '../../../domain/entities/reading_session.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ReadingSessionRepository _sessionRepository;

  AnalyticsProvider(this._sessionRepository);

  // State
  bool _isLoading = false;
  String? _errorMessage;
  ReadingStats? _stats;
  List<ReadingProgress> _progressData = [];
  ReadingStreak? _streak;
  List<ReadingGoal> _goals = [];
  List<ReadingSession> _recentSessions = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReadingStats? get stats => _stats;
  List<ReadingProgress> get progressData => List.unmodifiable(_progressData);
  ReadingStreak? get streak => _streak;
  List<ReadingGoal> get goals => List.unmodifiable(_goals);
  List<ReadingSession> get recentSessions => List.unmodifiable(_recentSessions);

  // Computed properties
  int get totalWordsRead => _stats?.totalWordsRead ?? 0;
  double get averageSpeed => _stats?.averageWordsPerMinute ?? 0.0;
  int get currentStreak => _streak?.currentStreak ?? 0;
  int get longestStreak => _streak?.longestStreak ?? 0;
  bool hasActiveStreak => _streak?.isActive ?? false;

  // Load analytics data
  Future<void> loadAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load all analytics data in parallel
      final results = await Future.wait([
        _sessionRepository.getReadingStats(startDate: startDate, endDate: endDate),
        _sessionRepository.getReadingStreak(),
        _sessionRepository.getReadingGoals(),
        _sessionRepository.getRecentSessions(limit: 10),
      ]);

      _stats = results[0] as ReadingStats;
      _streak = results[1] as ReadingStreak;
      _goals = results[2] as List<ReadingGoal>;
      _recentSessions = results[3] as List<ReadingSession>;

      // Load progress data for the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      _progressData = await _sessionRepository.getReadingProgress(
        startDate: thirtyDaysAgo,
        endDate: DateTime.now(),
        interval: ProgressInterval.daily,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load analytics data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load progress data with custom date range and interval
  Future<void> loadProgressData({
    required DateTime startDate,
    required DateTime endDate,
    ProgressInterval interval = ProgressInterval.daily,
  }) async {
    try {
      _progressData = await _sessionRepository.getReadingProgress(
        startDate: startDate,
        endDate: endDate,
        interval: interval,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load progress data: $e';
      notifyListeners();
    }
  }

  // Update reading goal
  Future<void> updateGoal(ReadingGoal goal) async {
    try {
      await _sessionRepository.updateReadingGoal(goal);
      
      // Refresh goals
      _goals = await _sessionRepository.getReadingGoals();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update goal: $e';
      notifyListeners();
    }
  }

  // Create new reading goal
  Future<void> createGoal({
    required String title,
    required String description,
    required ReadingGoalType type,
    required double target,
    required DateTime endDate,
  }) async {
    try {
      final goal = ReadingGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        type: type,
        target: target,
        current: 0.0,
        startDate: DateTime.now(),
        endDate: endDate,
        isCompleted: false,
      );

      await _sessionRepository.updateReadingGoal(goal);
      
      // Refresh goals
      _goals = await _sessionRepository.getReadingGoals();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create goal: $e';
      notifyListeners();
    }
  }

  // Delete reading goal
  Future<void> deleteGoal(String goalId) async {
    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just remove from local list
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete goal: $e';
      notifyListeners();
    }
  }

  // Get session details
  Future<ReadingSession?> getSessionDetails(int sessionId) async {
    try {
      return await _sessionRepository.getSessionById(sessionId);
    } catch (e) {
      _errorMessage = 'Failed to get session details: $e';
      notifyListeners();
      return null;
    }
  }

  // Get sessions for a specific PDF
  Future<List<ReadingSession>> getSessionsForPdf(String pdfId) async {
    try {
      return await _sessionRepository.getSessionsForPdf(pdfId);
    } catch (e) {
      _errorMessage = 'Failed to get sessions for PDF: $e';
      notifyListeners();
      return [];
    }
  }

  // Refresh analytics data
  Future<void> refresh() async {
    await loadAnalyticsData();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Analytics insights
  List<AnalyticsInsight> getInsights() {
    final insights = <AnalyticsInsight>[];

    if (_stats == null) return insights;

    // Speed insight
    if (_stats!.averageWordsPerMinute < 150) {
      insights.add(AnalyticsInsight(
        type: InsightType.speed,
        title: 'Reading Speed',
        description: 'Your average speed is below recommended levels. Try increasing gradually.',
        severity: InsightSeverity.info,
        action: 'Adjust Speed Settings',
      ));
    } else if (_stats!.averageWordsPerMinute > 350) {
      insights.add(AnalyticsInsight(
        type: InsightType.speed,
        title: 'Great Reading Speed',
        description: 'Your reading speed is excellent! Consider focusing on comprehension.',
        severity: InsightSeverity.success,
        action: null,
      ));
    }

    // Streak insight
    if (_streak?.currentStreak == 1) {
      insights.add(AnalyticsInsight(
        type: InsightType.streak,
        title: 'Keep Going!',
        description: 'You\'re on a 1-day streak. Make it a habit!',
        severity: InsightSeverity.info,
        action: 'Set Daily Goal',
      ));
    } else if (_streak?.currentStreak != null && _streak!.currentStreak >= 7) {
      insights.add(AnalyticsInsight(
        type: InsightType.streak,
        title: 'Amazing Streak!',
        description: 'You\'ve been reading for ${_streak!.currentStreak} days straight!',
        severity: InsightSeverity.success,
        action: null,
      ));
    }

    // Session frequency insight
    if (_stats!.totalSessions < 5) {
      insights.add(AnalyticsInsight(
        type: InsightType.frequency,
        title: 'Read More Often',
        description: 'Try to read at least 5 times per week for better progress.',
        severity: InsightSeverity.warning,
        action: 'Set Reading Schedule',
      ));
    }

    return insights;
  }

  // Goal progress summary
  GoalProgressSummary getGoalProgressSummary() {
    if (_goals.isEmpty) {
      return const GoalProgressSummary(
        totalGoals: 0,
        completedGoals: 0,
        inProgressGoals: 0,
        expiredGoals: 0,
        overallProgress: 0.0,
      );
    }

    final completed = _goals.where((g) => g.isCompleted).length;
    final expired = _goals.where((g) => g.isExpired && !g.isCompleted).length;
    final inProgress = _goals.length - completed - expired;
    final overallProgress = _goals.isEmpty 
        ? 0.0 
        : _goals.map((g) => g.progress).reduce((a, b) => a + b) / _goals.length;

    return GoalProgressSummary(
      totalGoals: _goals.length,
      completedGoals: completed,
      inProgressGoals: inProgress,
      expiredGoals: expired,
      overallProgress: overallProgress,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class AnalyticsInsight {
  final InsightType type;
  final String title;
  final String description;
  final InsightSeverity severity;
  final String? action;

  const AnalyticsInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    this.action,
  });
}

enum InsightType {
  speed,
  streak,
  frequency,
  comprehension,
  goals,
}

enum InsightSeverity {
  info,
  success,
  warning,
  error,
}

class GoalProgressSummary {
  final int totalGoals;
  final int completedGoals;
  final int inProgressGoals;
  final int expiredGoals;
  final double overallProgress;

  const GoalProgressSummary({
    required this.totalGoals,
    required this.completedGoals,
    required this.inProgressGoals,
    required this.expiredGoals,
    required this.overallProgress,
  });

  double get completionRate => totalGoals > 0 ? completedGoals / totalGoals : 0.0;
}
