import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/reading_display/providers/reading_display_provider.dart';
import '../../features/user_preferences/providers/user_preferences_provider.dart';

class ReadingControlsWidget extends StatelessWidget {
  const ReadingControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReadingDisplayProvider, UserPreferencesProvider>(
      builder: (context, readingProvider, preferencesProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Controls
              _buildMainControls(context, readingProvider),
              const SizedBox(height: 16),
              
              // Speed Control
              _buildSpeedControl(context, readingProvider, preferencesProvider),
              const SizedBox(height: 16),
              
              // Additional Controls
              _buildAdditionalControls(context, readingProvider, preferencesProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainControls(BuildContext context, ReadingDisplayProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous/Back Button
        IconButton.outlined(
          onPressed: provider.hasContent ? () => _jumpBackward(provider) : null,
          icon: const Icon(Icons.skip_backward),
          tooltip: 'Jump Back',
        ),
        
        // Play/Pause Button
        FloatingActionButton.extended(
          onPressed: provider.hasContent ? () => _togglePlayPause(provider) : null,
          icon: Icon(
            provider.isReading ? Icons.pause : Icons.play_arrow,
          ),
          label: Text(
            provider.isReading ? 'Pause' : provider.isPaused ? 'Resume' : 'Start',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        
        // Next/Forward Button
        IconButton.outlined(
          onPressed: provider.hasContent ? () => _jumpForward(provider) : null,
          icon: const Icon(Icons.skip_forward),
          tooltip: 'Jump Forward',
        ),
      ],
    );
  }

  Widget _buildSpeedControl(
    BuildContext context,
    ReadingDisplayProvider readingProvider,
    UserPreferencesProvider preferencesProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reading Speed',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${preferencesProvider.readingSpeed.round()} WPM',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Speed Presets
            ...[150, 200, 250, 300].map((speed) {
              final isSelected = preferencesProvider.readingSpeed.round() == speed;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('$speed'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      readingProvider.adjustSpeed(speed.toDouble());
                    }
                  },
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            }),
            
            // Custom Speed Slider
            Expanded(
              child: Slider(
                value: preferencesProvider.readingSpeed,
                min: 50,
                max: 500,
                divisions: 45,
                onChanged: (value) {
                  readingProvider.adjustSpeed(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(
    BuildContext context,
    ReadingDisplayProvider readingProvider,
    UserPreferencesProvider preferencesProvider,
  ) {
    return Row(
      children: [
        // Line Spacing
        Expanded(
          child: _buildControlButton(
            context,
            icon: Icons.line_spacing,
            label: 'Spacing',
            value: '${preferencesProvider.lineSpacing}x',
            onTap: () => _showLineSpacingDialog(context, preferencesProvider),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Font Size
        Expanded(
          child: _buildControlButton(
            context,
            icon: Icons.format_size,
            label: 'Font Size',
            value: '${preferencesProvider.fontSize}',
            onTap: () => _showFontSizeDialog(context, preferencesProvider),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Focus Window
        Expanded(
          child: _buildControlButton(
            context,
            icon: Icons.center_focus_strong,
            label: 'Focus',
            value: '${preferencesProvider.focusWindowSize}',
            onTap: () => _showFocusWindowDialog(context, preferencesProvider),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Settings
        Expanded(
          child: _buildControlButton(
            context,
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => _showSettingsDialog(context, preferencesProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            if (value != null) ...[
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _togglePlayPause(ReadingDisplayProvider provider) {
    if (provider.isReading) {
      provider.pauseReading();
    } else if (provider.isPaused) {
      provider.resumeReading();
    } else {
      provider.startReading();
    }
  }

  void _jumpBackward(ReadingDisplayProvider provider) {
    final currentProgress = provider.progress;
    final newProgress = (currentProgress - 0.1).clamp(0.0, 1.0);
    provider.jumpToPosition(newProgress);
  }

  void _jumpForward(ReadingDisplayProvider provider) {
    final currentProgress = provider.progress;
    final newProgress = (currentProgress + 0.1).clamp(0.0, 1.0);
    provider.jumpToPosition(newProgress);
  }

  void _showLineSpacingDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _LineSpacingDialog(provider: provider),
    );
  }

  void _showFontSizeDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _FontSizeDialog(provider: provider),
    );
  }

  void _showFocusWindowDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _FocusWindowDialog(provider: provider),
    );
  }

  void _showSettingsDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(provider: provider),
    );
  }
}

class _LineSpacingDialog extends StatefulWidget {
  final UserPreferencesProvider provider;
  
  const _LineSpacingDialog({required this.provider});

  @override
  State<_LineSpacingDialog> createState() => _LineSpacingDialogState();
}

class _LineSpacingDialogState extends State<_LineSpacingDialog> {
  double _spacing = 1.5;

  @override
  void initState() {
    super.initState();
    _spacing = widget.provider.lineSpacing;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Line Spacing'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current: ${_spacing.toStringAsFixed(1)}x'),
          Slider(
            value: _spacing,
            min: 1.0,
            max: 3.0,
            divisions: 20,
            onChanged: (value) => setState(() => _spacing = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.provider.updateLineSpacing(_spacing);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _FontSizeDialog extends StatefulWidget {
  final UserPreferencesProvider provider;
  
  const _FontSizeDialog({required this.provider});

  @override
  State<_FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<_FontSizeDialog> {
  int _fontSize = 16;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.provider.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Font Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current: $_fontSize'),
          Slider(
            value: _fontSize.toDouble(),
            min: 12,
            max: 24,
            divisions: 12,
            onChanged: (value) => setState(() => _fontSize = value.round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.provider.updateFontSize(_fontSize);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _FocusWindowDialog extends StatefulWidget {
  final UserPreferencesProvider provider;
  
  const _FocusWindowDialog({required this.provider});

  @override
  State<_FocusWindowDialog> createState() => _FocusWindowDialogState();
}

class _FocusWindowDialogState extends State<_FocusWindowDialog> {
  int _focusSize = 3;

  @override
  void initState() {
    super.initState();
    _focusSize = widget.provider.focusWindowSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Focus Window Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current: $_focusSize words'),
          Slider(
            value: _focusSize.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) => setState(() => _focusSize = value.round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.provider.updateFocusWindowSize(_focusSize);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  final UserPreferencesProvider provider;
  
  const _SettingsDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reading Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Beginner Preset'),
            subtitle: const Text('150 WPM, 2.0x spacing, 18pt font'),
            onTap: () {
              provider.applyBeginnerPreset();
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Intermediate Preset'),
            subtitle: const Text('200 WPM, 1.5x spacing, 16pt font'),
            onTap: () {
              provider.applyIntermediatePreset();
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Advanced Preset'),
            subtitle: const Text('300 WPM, 1.2x spacing, 14pt font'),
            onTap: () {
              provider.applyAdvancedPreset();
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Restore original settings'),
            onTap: () {
              provider.resetToDefaults();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
