import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/pdf_processing/providers/pdf_processing_provider.dart';
import '../../features/reading_display/providers/reading_display_provider.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfProcessingProvider, ReadingDisplayProvider>(
      builder: (context, pdfProvider, readingProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reading Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (readingProvider.hasContent)
                    _buildSessionIndicator(context, readingProvider),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats Grid
              _buildStatsGrid(context, pdfProvider, readingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionIndicator(BuildContext context, ReadingDisplayProvider provider) {
    Color color;
    IconData icon;
    String label;

    switch (provider.state) {
      case ReadingState.reading:
        color = Colors.green;
        icon = Icons.play_arrow;
        label = 'Reading';
        break;
      case ReadingState.paused:
        color = Colors.orange;
        icon = Icons.pause;
        label = 'Paused';
        break;
      case ReadingState.completed:
        color = Colors.blue;
        icon = Icons.check_circle;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle_outlined;
        label = 'Ready';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    PdfProcessingProvider pdfProvider,
    ReadingDisplayProvider readingProvider,
  ) {
    return Row(
      children: [
        // Documents Stat
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.description,
            label: 'Documents',
            value: pdfProvider.totalDocuments.toString(),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Current Speed Stat
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.speed,
            label: 'Speed',
            value: '${readingProvider.averageSpeed.round()}',
            suffix: 'WPM',
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Words Read Stat
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.text_fields,
            label: 'Words',
            value: readingProvider.wordsRead.toString(),
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? suffix,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Text(
                  suffix,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
