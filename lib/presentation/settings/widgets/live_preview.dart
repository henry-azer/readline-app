import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/user_preferences_model.dart';

/// Sample text used in the live preview — reflects focus-window reading zones.
const _kFocusText =
    'The quiet architecture of a library is not merely in its walls, but in the collective breath of those immersed in the written word.';

const _kUpcomingText =
    'Here, time does not move in minutes, but in pages turned and ideas sparked. Every margin note is a whisper across decades, a dialogue with the ghosts of thinkers past who found solace in these very same ink-stained paths.';

/// A real-time preview panel that reflects font, size, line spacing and
/// focus-window settings without any user action.
class LivePreview extends StatelessWidget {
  final UserPreferencesModel prefs;

  const LivePreview({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final tertiaryContainer = isDark
        ? AppColors.tertiaryContainer
        : AppColors.lightTertiaryContainer;
    final tertiary = isDark ? AppColors.tertiary : AppColors.lightTertiary;

    // Resolve reading font from preference
    final readingStyle = AppTypography.readingFont(
      prefs.fontFamily,
      fontSize: prefs.fontSize.toDouble(),
    ).copyWith(height: prefs.lineSpacing, color: onSurface);

    final upcomingStyle = readingStyle.copyWith(
      color: onSurfaceVariant.withValues(alpha: 0.55),
      fontSize: (prefs.fontSize - 1).clamp(11, 48).toDouble(),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.lgBorder,
        boxShadow: [
          AppColors.ambientShadow(blur: 16, opacity: isDark ? 0.25 : 0.06),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Focus mode indicator ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppStrings.settingsPreviewFocusMode.tr,
                  style: AppTypography.label.copyWith(
                    color: primary,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Text preview ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Focus zone — highlighted word inline
                _FocusZoneText(
                  text: _kFocusText,
                  style: readingStyle,
                  highlightColor: tertiary.withValues(alpha: 0.25),
                  highlightBorder: tertiaryContainer,
                  highlightWord: 'quiet architecture',
                ),

                const SizedBox(height: AppSpacing.xs),

                // Upcoming zone
                Text(
                  _kUpcomingText,
                  style: upcomingStyle,
                  maxLines: 4,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),

          // ── Stats bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceContainerHigh
                  : AppColors.lightSurfaceContainerLow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                  value: '${prefs.fontSize}',
                  label: AppStrings.settingsPreviewPtSize.tr,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                ),
                _StatChip(
                  value: prefs.lineSpacing.toStringAsFixed(1),
                  label: AppStrings.settingsPreviewLineH.tr,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                ),
                _StatChip(
                  value: '${prefs.readingSpeedWpm}',
                  label: AppStrings.settingsPreviewWpm.tr,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Focus zone text with highlighted word ─────────────────────────────────────

class _FocusZoneText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color highlightColor;
  final Color highlightBorder;
  final String highlightWord;

  const _FocusZoneText({
    required this.text,
    required this.style,
    required this.highlightColor,
    required this.highlightBorder,
    required this.highlightWord,
  });

  @override
  Widget build(BuildContext context) {
    final idx = text.toLowerCase().indexOf(highlightWord.toLowerCase());
    if (idx < 0) {
      return Text(text, style: style);
    }

    final before = text.substring(0, idx);
    final word = text.substring(idx, idx + highlightWord.length);
    final after = text.substring(idx + highlightWord.length);

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: highlightBorder.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                word,
                style: style.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color onSurface;
  final Color onSurfaceVariant;

  const _StatChip({
    required this.value,
    required this.label,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: onSurfaceVariant,
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
