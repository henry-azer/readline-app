import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Four-card row for choosing the reading font family. Each card renders an
/// "Aa" preview in the actual selected font.
class FontFamilyCardRow extends StatelessWidget {
  final String selected;
  final Color primary;
  final Color onSurfaceVariant;
  final Color trackColor;
  final ValueChanged<String> onChanged;

  static const _families = <({String id, String labelKey, String category})>[
    (id: 'newsreader', labelKey: 'player.fontSerif', category: 'Serif'),
    (id: 'inter', labelKey: 'player.fontSans', category: 'Sans'),
    (id: 'jetBrainsMono', labelKey: 'player.fontMono', category: 'Mono'),
    (id: 'openSans', labelKey: 'player.fontDyslexic', category: 'Sans'),
  ];

  const FontFamilyCardRow({
    super.key,
    required this.selected,
    required this.primary,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.onChanged,
  });

  String _resolveSelection(String id) {
    for (final f in _families) {
      if (f.id == id) return id;
    }
    // Map non-card fonts to their category
    final serifFonts = [
      'newsreader',
      'literata',
      'merriweather',
      'lora',
      'playfairDisplay',
      'sourceSerif4',
      'ebGaramond',
      'crimsonText',
      'vollkorn',
      'notoSerif',
      'robotoSlab',
      'ibmPlexSerif',
    ];
    final sansFonts = [
      'inter',
      'openSans',
      'roboto',
      'nunito',
      'poppins',
      'dmSans',
      'ibmPlexSans',
    ];
    final monoFonts = ['jetBrainsMono', 'firaMono'];
    if (serifFonts.contains(id)) return 'newsreader';
    if (monoFonts.contains(id)) return 'jetBrainsMono';
    if (sansFonts.contains(id)) return 'inter';
    return 'newsreader';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSelection = _resolveSelection(selected);
    return Row(
      children: _families.map((f) {
        final isActive = resolvedSelection == f.id;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onChanged(f.id),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                height: 56,
                decoration: BoxDecoration(
                  color: isActive
                      ? primary.withValues(alpha: 0.12)
                      : onSurfaceVariant.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                  border: Border.all(
                    color: isActive ? primary : AppColors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aa',
                      style: AppTypography.readingFont(
                        f.id,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: isActive ? primary : onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.micro),
                    Text(
                      f.labelKey.tr,
                      style: AppTypography.readingTinyLabel.copyWith(
                        color: isActive ? primary : onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
