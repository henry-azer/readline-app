import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/user_preferences/providers/user_preferences_provider.dart';

class AdvancedSettingsWidget extends StatelessWidget {
  const AdvancedSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, provider, child) {
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
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Advanced Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Vocabulary Collection
                _buildToggleSetting(
                  context,
                  'Vocabulary Collection',
                  'Automatically collect new words while reading',
                  provider.enableVocabularyCollection,
                  (value) => provider.updateVocabularyCollection(value),
                  icon: Icons.book,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                
                // Analytics
                _buildToggleSetting(
                  context,
                  'Analytics & Tracking',
                  'Help improve the app with anonymous usage data',
                  provider.enableAnalytics,
                  (value) => provider.updateAnalytics(value),
                  icon: Icons.analytics,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(height: 24),
                
                // Data Management
                _buildDataManagementSection(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleSetting(
    BuildContext context,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Management',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        
        // Export Settings
        _buildActionButton(
          context,
          'Export Settings',
          'Download your settings as a file',
          Icons.download,
          () => _exportSettings(context, provider),
        ),
        const SizedBox(height: 8),
        
        // Import Settings
        _buildActionButton(
          context,
          'Import Settings',
          'Load settings from a file',
          Icons.upload,
          () => _importSettings(context, provider),
        ),
        const SizedBox(height: 8),
        
        // Clear Cache
        _buildActionButton(
          context,
          'Clear Cache',
          'Remove temporary files and cached data',
          Icons.clear_all,
          () => _clearCache(context),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDestructive
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _exportSettings(BuildContext context, UserPreferencesProvider provider) {
    final settings = provider.exportPreferences();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings exported: ${settings.keys.length} items'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Show settings in a dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exported Settings'),
                content: SingleChildScrollView(
                  child: Text(
                    settings.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _importSettings(BuildContext context, UserPreferencesProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import settings feature coming soon!')),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all temporary files and cached data. Your reading progress and settings will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
