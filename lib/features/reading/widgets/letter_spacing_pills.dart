import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_tracking.dart';
import 'package:readline_app/core/theme/app_typography.dart';


/// Three-pill row for choosing letter spacing (tight / normal / wide). Each
/// pill renders its own label with the corresponding letter-spacing value
/// applied so users can preview the effect.
class LetterSpacingPills extends StatelessWidget {
  final String selected;
  final Color primary;
  final Color onSurfaceVariant;
  final Color trackColor;
  final ValueChanged<String> onChanged;

  static const _options = <({String id, String labelKey, double value})>[
    (
      id: 'tight',
      labelKey: 'player.letterSpacingTight',
      value: AppTracking.tight,
    ),
    (
      id: 'normal',
      labelKey: 'player.letterSpacingNormal',
      value: AppTracking.normal,
    ),
    (id: 'wide', labelKey: 'player.letterSpacingWide', value: AppTracking.wide),
  ];

  const LetterSpacingPills({
    super.key,
    required this.selected,
    required this.primary,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((o) {
        final isActive = selected == o.id;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onChanged(o.id),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? primary
                      : onSurfaceVariant.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                ),
                alignment: Alignment.center,
                // The letter-spacing on each label is functional — it
                // demonstrates the value the option will apply.
                child: Text(
                  o.labelKey.tr,
                  style: AppTypography.readingMicroLabel.copyWith(
                    color: isActive ? AppColors.white : onSurfaceVariant,
                    letterSpacing: o.value,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
