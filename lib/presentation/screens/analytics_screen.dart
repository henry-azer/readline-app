import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/analytics/providers/analytics_provider.dart';
import '../widgets/analytics/stats_overview_widget.dart';
import '../widgets/analytics/progress_chart_widget.dart';
import '../widgets/analytics/reading_streak_widget.dart';
import '../widgets/analytics/recent_sessions_widget.dart';
import '../widgets/analytics/insights_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AnalyticsProvider>().refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading analytics...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analytics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Overview
                  const StatsOverviewWidget(),
                  const SizedBox(height: 24),
                  
                  // Reading Streak
                  const ReadingStreakWidget(),
                  const SizedBox(height: 24),
                  
                  // Progress Chart
                  const ProgressChartWidget(),
                  const SizedBox(height: 24),
                  
                  // Insights
                  const InsightsWidget(),
                  const SizedBox(height: 24),
                  
                  // Recent Sessions
                  const RecentSessionsWidget(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
