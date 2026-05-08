import 'dart:math' as math;
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_tracking.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/widgets/readline_button.dart';

class CelebrationOverlay extends StatefulWidget {
  final CelebrationData celebration;
  final VoidCallback onContinue;
  final bool showKeepReading;

  const CelebrationOverlay({
    super.key,
    required this.celebration,
    required this.onContinue,
    this.showKeepReading = false,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _confettiController = ConfettiController(
      duration: AppDurations.celebrationEntry,
    );

    _animController.forward();
    _confettiController.play();
    // No auto-dismiss timer — popup stays until the user closes it via the X
    // or the Continue / Keep Reading button. Padlock-checkpoint feel.
  }

  void _dismiss() {
    _animController.reverse().then((_) {
      if (mounted) widget.onContinue();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final celebration = widget.celebration;
    final tierColors = _tierColors(celebration.tier, isDark);

    final confettiColors = [
      tierColors.$1,
      tierColors.$2,
      primaryColor,
      isDark ? AppColors.tertiary : AppColors.lightTertiary,
    ];

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        // Stack with Clip.none lets the confetti emitter sit just above the
        // card top and rain particles down through the card surface.
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            _buildCard(context, isDark, tierColors),

            // Confetti emitters — five points evenly spread across the card's
            // top edge so confetti rains down across the FULL width of the
            // popup, not from a single center column.
            Positioned(
              top: -16,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (_) => ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.directional,
                      blastDirection: math.pi / 2,
                      shouldLoop: false,
                      colors: confettiColors,
                      numberOfParticles: 2,
                      maxBlastForce: 8,
                      minBlastForce: 3,
                      emissionFrequency: 0.04,
                      gravity: 0.35,
                      particleDrag: 0.06,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: AppColors.transparent,
        child: Stack(
          children: [
            // Scrim — blurred with a barely-there ~8% black tint so the
            // underlying screen reads clearly behind the popup. The card
            // itself is solid (not glass) so it stays crisp.
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: const ColoredBox(color: Color(0x14000000)),
              ),
            ),

            // Center card (with confetti raining inside its top edge)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: card,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card body ──────────────────────────────────────────────────────────────

  Widget _buildCard(
    BuildContext context,
    bool isDark,
    (Color, Color) tierColors,
  ) {
    final cardBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;
    final borderColor = (isDark
            ? AppColors.outlineVariant
            : AppColors.lightOutlineVariant)
        .withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: tierColors.$1.withValues(alpha: 0.18),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top-leading X close button (padlock-checkpoint style)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: isDark
                    ? AppColors.onSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
              onPressed: _dismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Type-specific body
          if (widget.celebration.type == CelebrationType.streakMilestone)
            _StreakBody(
              celebration: widget.celebration,
              tierColors: tierColors,
              isDark: isDark,
            )
          else
            _StandardBody(
              celebration: widget.celebration,
              tierColors: tierColors,
              isDark: isDark,
              title: _resolveTitle(widget.celebration),
              message: _resolveMessage(widget.celebration),
            ),

          const SizedBox(height: AppSpacing.xl),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ReadlineButton(
              label: widget.showKeepReading
                  ? AppStrings.celebrationKeepReading.tr
                  : AppStrings.celebrationContinue.tr,
              onTap: _dismiss,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveTitle(CelebrationData celebration) {
    return switch (celebration.type) {
      CelebrationType.streakMilestone =>
        AppStrings.celebrationStreakTitle.trParams({
          'n': '${celebration.streakCount}',
        }),
      CelebrationType.dailyTarget => AppStrings.celebrationDailyTargetTitle.tr,
      CelebrationType.wordsMilestone =>
        AppStrings.celebrationWordsTitle.trParams({
          'n': _formatWordCount(celebration.wordsCount),
        }),
    };
  }

  String _resolveMessage(CelebrationData celebration) {
    if (celebration.messageKey == 'celebration.combinedMessage') {
      return AppStrings.celebrationCombinedMessage.trParams({
        'n': '${celebration.streakCount}',
      });
    }
    return switch (celebration.type) {
      CelebrationType.streakMilestone =>
        AppStrings.celebrationStreakMessage.trParams({
          'n': '${celebration.streakCount}',
        }),
      CelebrationType.dailyTarget =>
        AppStrings.celebrationDailyTargetMessage.trParams({
          'n': '${celebration.minutesRead.round()}',
        }),
      CelebrationType.wordsMilestone =>
        AppStrings.celebrationWordsMessage.trParams({
          'n': _formatWordCount(celebration.wordsCount),
        }),
    };
  }

  String _formatWordCount(int count) {
    if (count >= 1000) return '${(count / 1000).round()}K';
    return '$count';
  }

  (Color, Color) _tierColors(CelebrationTier tier, bool isDark) =>
      _resolveTierColors(tier, isDark);
}

// ── Tier helpers ──────────────────────────────────────────────────────────────

(Color, Color) _resolveTierColors(CelebrationTier tier, bool isDark) {
  return switch (tier) {
    CelebrationTier.bronze => (
      isDark ? AppColors.tierBronze : AppColors.lightTierBronze,
      isDark ? AppColors.tierBronzeEnd : AppColors.lightTierBronzeEnd,
    ),
    CelebrationTier.silver => (
      isDark ? AppColors.tierSilver : AppColors.lightTierSilver,
      isDark ? AppColors.tierSilverEnd : AppColors.lightTierSilverEnd,
    ),
    CelebrationTier.gold => (
      isDark ? AppColors.tierGold : AppColors.lightTierGold,
      isDark ? AppColors.tierGoldEnd : AppColors.lightTierGoldEnd,
    ),
    CelebrationTier.platinum => (
      isDark ? AppColors.tierPlatinum : AppColors.lightTierPlatinum,
      isDark ? AppColors.tierPlatinumEnd : AppColors.lightTierPlatinumEnd,
    ),
    CelebrationTier.diamond => (
      isDark ? AppColors.tierDiamond : AppColors.lightTierDiamond,
      isDark ? AppColors.tierDiamondEnd : AppColors.lightTierDiamondEnd,
    ),
  };
}

String _tierLabel(CelebrationTier tier) {
  return switch (tier) {
    CelebrationTier.bronze => AppStrings.celebrationTierBronze.tr,
    CelebrationTier.silver => AppStrings.celebrationTierSilver.tr,
    CelebrationTier.gold => AppStrings.celebrationTierGold.tr,
    CelebrationTier.platinum => AppStrings.celebrationTierPlatinum.tr,
    CelebrationTier.diamond => AppStrings.celebrationTierDiamond.tr,
  };
}

IconData _tierIcon(CelebrationTier tier) {
  return switch (tier) {
    CelebrationTier.bronze => Icons.local_fire_department_rounded,
    CelebrationTier.silver => Icons.auto_awesome_rounded,
    CelebrationTier.gold => Icons.emoji_events_rounded,
    CelebrationTier.platinum => Icons.diamond_rounded,
    CelebrationTier.diamond => Icons.workspace_premium_rounded,
  };
}

// ── Streak body (padlock-checkpoint style) ───────────────────────────────────

class _StreakBody extends StatelessWidget {
  final CelebrationData celebration;
  final (Color, Color) tierColors;
  final bool isDark;

  const _StreakBody({
    required this.celebration,
    required this.tierColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final mutedColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final messageKey = celebration.messageKey;
    final message = messageKey == 'celebration.combinedMessage'
        ? AppStrings.celebrationCombinedMessage.trParams({
            'n': '${celebration.streakCount}',
          })
        : AppStrings.celebrationStreakMessage.trParams({
            'n': '${celebration.streakCount}',
          });

    final numberGradient = LinearGradient(
      colors: [tierColors.$1, tierColors.$2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fire emoji — same character padlock uses for its checkpoint.
        const Text('\u{1F525}', style: TextStyle(fontSize: 48)),
        const SizedBox(height: AppSpacing.md),

        // Big streak number with tier gradient
        ShaderMask(
          shaderCallback: (rect) => numberGradient.createShader(rect),
          child: Text(
            '${celebration.streakCount}',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: AppColors.onSurface, // overridden by ShaderMask
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),

        // "DAY STREAK" tier-coloured label
        ShaderMask(
          shaderCallback: (rect) => numberGradient.createShader(rect),
          child: Text(
            AppStrings.homeStreakLabel.tr,
            style: AppTypography.button.copyWith(
              letterSpacing: AppTracking.editorial,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface, // overridden by ShaderMask
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Tier name pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: tierColors.$1.withValues(alpha: 0.15),
            borderRadius: AppRadius.fullBorder,
          ),
          child: Text(
            _tierLabel(celebration.tier),
            style: AppTypography.celebrationTierLabel.copyWith(
              color: tierColors.$1,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Message
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: mutedColor,
            height: 1.4,
          ),
        ),

        // Subtle "+ minutes today" line for the combined milestone
        if (celebration.minutesRead > 0 &&
            messageKey == 'celebration.combinedMessage') ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.celebrationDailyTargetMessage.trParams({
              'n': '${celebration.minutesRead.round()}',
            }),
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Standard body (daily target / words milestone) ───────────────────────────

class _StandardBody extends StatelessWidget {
  final CelebrationData celebration;
  final (Color, Color) tierColors;
  final bool isDark;
  final String title;
  final String message;

  const _StandardBody({
    required this.celebration,
    required this.tierColors,
    required this.isDark,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onPrimary = isDark ? AppColors.onPrimary : AppColors.lightOnPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tier badge — gradient-filled circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [tierColors.$1, tierColors.$2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(_tierIcon(celebration.tier), size: 36, color: onPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Tier label pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: tierColors.$1.withValues(alpha: 0.15),
            borderRadius: AppRadius.fullBorder,
          ),
          child: Text(
            _tierLabel(celebration.tier),
            style: AppTypography.celebrationTierLabel.copyWith(
              color: tierColors.$1,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headlineMedium.copyWith(color: onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Message
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
