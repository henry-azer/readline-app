import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/reading_display/providers/reading_display_provider.dart';
import '../../features/user_preferences/providers/user_preferences_provider.dart';

class ReadingDisplayWidget extends StatelessWidget {
  const ReadingDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReadingDisplayProvider, UserPreferencesProvider>(
      builder: (context, readingProvider, preferencesProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(context, readingProvider),
              const SizedBox(height: 16),
              
              // Reading Content
              Expanded(
                child: _buildReadingContent(context, readingProvider, preferencesProvider),
              ),
              
              // Current Word Display
              _buildCurrentWordDisplay(context, readingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, ReadingDisplayProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(provider.progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: provider.progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingContent(
    BuildContext context,
    ReadingDisplayProvider readingProvider,
    UserPreferencesProvider preferencesProvider,
  ) {
    if (!readingProvider.hasContent) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No content loaded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Import a PDF to start reading',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildScrollableText(context, readingProvider, preferencesProvider),
      ),
    );
  }

  Widget _buildScrollableText(
    BuildContext context,
    ReadingDisplayProvider readingProvider,
    UserPreferencesProvider preferencesProvider,
  ) {
    final content = readingProvider.currentContent;
    final fontSize = preferencesProvider.fontSize.toDouble();
    final lineSpacing = preferencesProvider.lineSpacing;
    final fontFamily = preferencesProvider.fontFamily;

    return SingleChildScrollView(
      controller: _createScrollController(readingProvider),
      padding: EdgeInsets.all(16.0),
      child: SelectableText(
        content,
        style: TextStyle(
          fontSize: fontSize,
          height: lineSpacing,
          fontFamily: fontFamily,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  ScrollController _createScrollController(ReadingDisplayProvider provider) {
    final controller = ScrollController();
    
    // Auto-scroll based on reading position
    if (provider.isReading && provider.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.animateTo(
            provider.currentPosition!.offset,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
      });
    }
    
    return controller;
  }

  Widget _buildCurrentWordDisplay(BuildContext context, ReadingDisplayProvider provider) {
    final currentWord = provider.currentPosition?.currentWord;
    
    if (currentWord == null || currentWord.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Current Word',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentWord,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric(
                context,
                'Speed',
                '${provider.averageSpeed.toStringAsFixed(0)} WPM',
              ),
              _buildMetric(
                context,
                'Time',
                '${provider.totalReadingTime.inMinutes}:${(provider.totalReadingTime.inSeconds % 60).toString().padLeft(2, '0')}',
              ),
              _buildMetric(
                context,
                'Words',
                '${provider.wordsRead}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
