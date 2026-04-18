import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/analytics/providers/analytics_provider.dart';

class ReadingStreakWidget extends StatelessWidget {
  const ReadingStreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final streak = provider.streak;
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reading Streak',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (streak != null) ...[
                  _buildStreakContent(context, streak),
                ] else ...[
                  _buildEmptyStreak(context),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakContent(BuildContext context, streak) {
    final isActive = streak.isActive;
    final streakColor = isActive ? Colors.orange : Colors.grey;
    
    return Column(
      children: [
        // Current Streak Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                streakColor.withOpacity(0.1),
                streakColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: streakColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: streakColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${streak.currentStreak}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: streakColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'days',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: streakColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isActive ? 'Keep it going!' : 'Streak ended',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: streakColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Streak Stats
        Row(
          children: [
            Expanded(
              child: _buildStreakStat(
                context,
                'Longest Streak',
                '${streak.longestStreak} days',
                Icons.emoji_events,
                Colors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStreakStat(
                context,
                'Total Reading Days',
                '${streak.recentReadingDays.length}',
                Icons.calendar_today,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        
        // Recent Reading Days
        if (streak.recentReadingDays.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildRecentDays(context, streak),
        ],
      ],
    );
  }

  Widget _buildStreakStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDays(BuildContext context, streak) {
    final recentDays = streak.recentReadingDays.take(7).toList();
    final today = DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final date = today.subtract(Duration(days: 6 - index));
            final hasRead = recentDays.any((readingDay) =>
                readingDay.year == date.year &&
                readingDay.month == date.month &&
                readingDay.day == date.day,
            );
            
            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasRead ? Colors.orange : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: hasRead
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDayAbbreviation(date.weekday),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasRead ? Colors.orange : Colors.grey,
                    fontWeight: hasRead ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyStreak(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Reading Streak',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Read every day to build your streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/home'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Reading'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
