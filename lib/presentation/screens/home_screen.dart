import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/pdf_processing/providers/pdf_processing_provider.dart';
import '../../features/reading_display/providers/reading_display_provider.dart';
import '../../features/user_preferences/providers/user_preferences_provider.dart';
import '../widgets/pdf_import_widget.dart';
import '../widgets/reading_controls_widget.dart';
import '../widgets/reading_display_widget.dart';
import '../widgets/stats_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read-It'),
        actions: [
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () => _showAnalytics(context),
            icon: const Icon(Icons.analytics),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer3<PdfProcessingProvider, ReadingDisplayProvider, UserPreferencesProvider>(
          builder: (context, pdfProvider, readingProvider, preferencesProvider, child) {
            return Column(
              children: [
                // Stats Bar
                const StatsWidget(),
                
                // Main Content Area
                Expanded(
                  child: _buildMainContent(context, pdfProvider, readingProvider),
                ),
                
                // Controls
                const ReadingControlsWidget(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<PdfProcessingProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () => _showPdfImport(context),
            label: const Text('Import PDF'),
            icon: const Icon(Icons.file_upload),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    PdfProcessingProvider pdfProvider,
    ReadingDisplayProvider readingProvider,
  ) {
    if (pdfProvider.isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing PDF...'),
          ],
        ),
      );
    }

    if (pdfProvider.errorMessage != null) {
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
              'Error processing PDF',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              pdfProvider.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pdfProvider.clearError,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (pdfProvider.currentDocument == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No PDF loaded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Import a PDF to start reading',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showPdfImport(context),
              icon: const Icon(Icons.file_upload),
              label: const Text('Import PDF'),
            ),
          ],
        ),
      );
    }

    return const ReadingDisplayWidget();
  }

  void _showPdfImport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PdfImportWidget(),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }

  void _showAnalytics(BuildContext context) {
    Navigator.of(context).pushNamed('/analytics');
  }
}
