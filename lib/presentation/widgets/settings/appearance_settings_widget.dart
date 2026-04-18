import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/user_preferences/providers/user_preferences_provider.dart';

class AppearanceSettingsWidget extends StatelessWidget {
  const AppearanceSettingsWidget({super.key});

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
                      Icons.palette,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Theme Mode
                _buildThemeModeControl(context, provider),
                const SizedBox(height: 20),
                
                // Font Family
                _buildFontFamilyControl(context, provider),
                const SizedBox(height: 20),
                
                // Preview Section
                _buildPreviewSection(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeModeControl(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.settings_system_daydream),
            ),
          ],
          selected: {provider.themeMode},
          onSelectionChanged: (Set<ThemeMode> selection) {
            provider.updateThemeMode(selection.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how the app appearance should look',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilyControl(BuildContext context, UserPreferencesProvider provider) {
    final fontFamilies = ['Inter', 'Roboto', 'Open Sans', 'Lato', 'Montserrat'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Family',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fontFamilies.map((font) {
            final isSelected = provider.fontFamily == font;
            return FilterChip(
              label: Text(font),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.updateFontFamily(font);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the font family for reading text',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context, UserPreferencesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sample Reading Text',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: provider.fontFamily,
                  fontSize: provider.fontSize.toDouble(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is how your reading text will appear with the current settings. '
                'You can adjust the font size, line spacing, and font family to find '
                'the perfect combination for comfortable reading.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: provider.fontFamily,
                  fontSize: provider.fontSize.toDouble(),
                  height: provider.lineSpacing,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.readingSpeed.round()} WPM',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.line_spacing,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.lineSpacing.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
