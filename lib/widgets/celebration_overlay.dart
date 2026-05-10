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
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/widgets/celebration_standard_body.dart';
import 'package:readline_app/widgets/celebration_streak_body.dart';
import 'package:readline_app/widgets/celebration_tier_helpers.dart';
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
    final tierColors = resolveTierColors(celebration.tier, isDark);

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
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            _buildCard(context, isDark, tierColors),

            // Confetti emitters spread across the card's top edge so confetti
            // rains down across the FULL width of the popup.
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
            // Scrim — light blur with a barely-there ~8% black tint so the
            // underlying screen reads clearly behind the popup.
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: const ColoredBox(color: AppColors.scrim08),
              ),
            ),

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

          if (widget.celebration.type == CelebrationType.streakMilestone)
            CelebrationStreakBody(
              celebration: widget.celebration,
              tierColors: tierColors,
            )
          else
            CelebrationStandardBody(
              celebration: widget.celebration,
              tierColors: tierColors,
              title: _resolveTitle(widget.celebration),
              message: _resolveMessage(widget.celebration),
            ),

          const SizedBox(height: AppSpacing.xl),

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
}
