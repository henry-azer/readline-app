import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/services/reading_engine_service.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/entities/reading_state.dart';

/// Three-zone text reading display.
///
/// Zone 1 (top)    — past text: italic serif, dimmed
/// Zone 2 (center) — focus text: bold serif, full opacity, larger
/// Zone 3 (bottom) — upcoming text: regular serif, slightly dimmed
class ReadingDisplay extends StatelessWidget {
  final ReadingEngineService engine;
  final void Function(String word) onWordTap;

  const ReadingDisplay({
    super.key,
    required this.engine,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ReadingState>(
      stream: engine.state$.stream,
      initialData: engine.state$.value,
      builder: (context, snap) {
        final state = snap.data ?? engine.state$.value;
        return _ReadingZones(state: state, onWordTap: onWordTap);
      },
    );
  }
}

// ── Zones layout ───────────────────────────────────────────────────────────────

class _ReadingZones extends StatelessWidget {
  final ReadingState state;
  final void Function(String word) onWordTap;

  const _ReadingZones({required this.state, required this.onWordTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final dimColor = onSurface.withValues(alpha: 0.35);
    final upcomingColor = onSurface.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Zone 1: Past text ─────────────────────────────────────────────
        Flexible(
          flex: 3,
          child: _PastZone(text: state.pastText, color: dimColor),
        ),

        // ── Divider line (subtle gradient fade) ───────────────────────────
        _ZoneDivider(isDark: isDark),

        // ── Zone 2: Focus text ────────────────────────────────────────────
        Flexible(
          flex: 4,
          child: _FocusZone(
            text: state.focusText,
            highlightedWord: state.highlightedWord,
            onWordTap: onWordTap,
            isDark: isDark,
            onSurface: onSurface,
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        _ZoneDivider(isDark: isDark, flip: true),

        // ── Zone 3: Upcoming text ─────────────────────────────────────────
        Flexible(
          flex: 3,
          child: _UpcomingZone(text: state.upcomingText, color: upcomingColor),
        ),
      ],
    );
  }
}

// ── Past zone ─────────────────────────────────────────────────────────────────

class _PastZone extends StatelessWidget {
  final String text;
  final Color color;

  const _PastZone({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTypography.readingBodyPast.copyWith(color: color),
        maxLines: 5,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.left,
      ),
    );
  }
}

// ── Focus zone ────────────────────────────────────────────────────────────────

class _FocusZone extends StatelessWidget {
  final String text;
  final String? highlightedWord;
  final void Function(String) onWordTap;
  final bool isDark;
  final Color onSurface;

  const _FocusZone({
    required this.text,
    required this.highlightedWord,
    required this.onWordTap,
    required this.isDark,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return Center(
        child: Text(
          AppStrings.readingLoading.tr,
          style: AppTypography.readingBodyFocus.copyWith(color: onSurface),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      alignment: Alignment.center,
      child: _TappableText(
        text: text,
        highlightedWord: highlightedWord,
        baseStyle: AppTypography.readingBodyFocus.copyWith(color: onSurface),
        highlightColor: isDark
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.lightPrimary.withValues(alpha: 0.15),
        onWordTap: onWordTap,
      ),
    );
  }
}

// ── Upcoming zone ─────────────────────────────────────────────────────────────

class _UpcomingZone extends StatelessWidget {
  final String text;
  final Color color;

  const _UpcomingZone({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTypography.readingBody.copyWith(color: color),
        maxLines: 5,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.left,
      ),
    );
  }
}

// ── Zone divider (gradient fade) ──────────────────────────────────────────────

class _ZoneDivider extends StatelessWidget {
  final bool isDark;
  final bool flip;

  const _ZoneDivider({required this.isDark, this.flip = false});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: flip ? Alignment.bottomCenter : Alignment.topCenter,
          end: flip ? Alignment.topCenter : Alignment.bottomCenter,
          colors: [
            baseColor.withValues(alpha: 0),
            baseColor.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }
}

// ── Tappable word text ────────────────────────────────────────────────────────

/// Renders text with tappable words. Highlights [highlightedWord] if set.
class _TappableText extends StatelessWidget {
  final String text;
  final String? highlightedWord;
  final TextStyle baseStyle;
  final Color highlightColor;
  final void Function(String) onWordTap;

  const _TappableText({
    required this.text,
    required this.highlightedWord,
    required this.baseStyle,
    required this.highlightColor,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(RegExp(r'(\s+)'));
    final spans = <InlineSpan>[];

    for (final token in words) {
      final trimmed = token.trim().replaceAll(RegExp("[^a-zA-Z0-9'-]"), '');
      final isHighlighted =
          highlightedWord != null &&
          trimmed.toLowerCase() == highlightedWord!.toLowerCase();

      if (token.trim().isEmpty) {
        spans.add(const TextSpan(text: ' '));
        continue;
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: trimmed.isNotEmpty ? () => onWordTap(trimmed) : null,
            child: Container(
              padding: isHighlighted
                  ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
                  : EdgeInsets.zero,
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: highlightColor,
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                token.trim(),
                style: isHighlighted
                    ? baseStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: highlightColor,
                      )
                    : baseStyle,
              ),
            ),
          ),
        ),
      );

      spans.add(const TextSpan(text: ' '));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}
