import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_curves.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/data/entities/reading_state.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';
import 'package:readline_app/features/reading/screens/reading_screen.dart'
    show readingControlsBarApproxHeight;
import 'package:readline_app/features/reading/viewmodels/reading_viewmodel.dart';
import 'package:readline_app/features/reading/widgets/reading_controls.dart';
import 'package:readline_app/features/reading/widgets/reading_display.dart';
import 'package:readline_app/features/reading/widgets/reading_top_bar.dart';
import 'package:readline_app/features/reading/widgets/vocab_highlight.dart';

/// Main reading body composed of: reading display, top fade gradient, in-stack
/// top bar, popup scrim, vocab highlight bar, and player controls bar.
class ReadingBody extends StatelessWidget {
  final ReadingViewModel viewModel;
  final bool showVocabBar;
  final String? tappedWord;
  final void Function(String) onWordTap;
  final ValueListenable<bool> isCurrentWordSaved;
  final VoidCallback onVocabToggle;
  final VoidCallback onVocabDismiss;
  final VoidCallback onPlayPause;
  final VoidCallback onSpeedDecrease;
  final VoidCallback onSpeedIncrease;
  final VoidCallback onFontSizeDecrease;
  final VoidCallback onFontSizeIncrease;
  final ValueChanged<double> onSeek;
  final VoidCallback onBack;
  final VoidCallback onShowSettings;

  const ReadingBody({
    super.key,
    required this.viewModel,
    required this.showVocabBar,
    required this.tappedWord,
    required this.onWordTap,
    required this.isCurrentWordSaved,
    required this.onVocabToggle,
    required this.onVocabDismiss,
    required this.onPlayPause,
    required this.onSpeedDecrease,
    required this.onSpeedIncrease,
    required this.onFontSizeDecrease,
    required this.onFontSizeIncrease,
    required this.onSeek,
    required this.onBack,
    required this.onShowSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Resolve bg from prefs for fade gradient. Reading-theme override takes
    // precedence (matches the screen-level bg) so the gradient blends
    // seamlessly into the active theme.
    final prefsForBg = viewModel.preferences$.valueOrNull;
    final fadeBg = readingThemeColors(prefsForBg?.readingTheme)?.bg ??
        _resolveFadeBg(isDark, prefsForBg?.readingBackground ?? 'default');

    return StreamBuilder<ReadingState>(
      stream: viewModel.readingState$,
      initialData: viewModel.currentReadingState,
      builder: (context, snap) {
        final state = snap.data ?? viewModel.currentReadingState;

        return StreamBuilder<UserPreferencesModel?>(
          stream: viewModel.preferences$,
          builder: (context, prefsSnap) {
            final prefs = prefsSnap.data;

            final topBarHeight =
                MediaQuery.paddingOf(context).top + kToolbarHeight;
            final bottomSafe = MediaQuery.paddingOf(context).bottom;
            final controlsHeight = 12.0 + 3 + 12 + 56 + bottomSafe + 16;

            return Stack(
              children: [
                Positioned.fill(
                  child: ReadingDisplay(
                    engine: viewModel.engine,
                    onWordTap: onWordTap,
                    prefs: prefs,
                  ),
                ),

                // ── Top fade gradient — fully opaque behind AppBar, fades out below
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: topBarHeight + 120,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            fadeBg.withValues(alpha: 0),
                            fadeBg.withValues(alpha: 0.7),
                            fadeBg,
                            fadeBg,
                          ],
                          stops: const [0.0, 0.35, 0.6, 1.0],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                // ── Bottom fade gradient — fully opaque behind controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: controlsHeight + 250,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            fadeBg.withValues(alpha: 0),
                            fadeBg.withValues(alpha: 0.4),
                            fadeBg.withValues(alpha: 0.8),
                            fadeBg.withValues(alpha: 0.95),
                            fadeBg,
                          ],
                          stops: const [0.0, 0.25, 0.5, 0.7, 1.0],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                // ── In-stack top bar — rendered *before* the popup scrim so
                //    the scrim covers the action buttons just like the rest
                //    of the screen.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: ReadingTopBar(
                        viewModel: viewModel,
                        onBack: onBack,
                        onShowSettings: onShowSettings,
                      ),
                    ),
                  ),
                ),

                // ── Popup scrim — full-screen dim, but rendered *before* the
                //    vocab bar and player controls so they float on top.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: AppDurations.normal,
                      opacity: showVocabBar ? 1.0 : 0.0,
                      child: const ColoredBox(color: AppColors.scrim20),
                    ),
                  ),
                ),

                // ── Vocab highlight bar — pinned at bottom, renders BEHIND
                //    the controls.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: AppDurations.calm,
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: AppCurves.enter,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: (showVocabBar && tappedWord != null)
                        ? ValueListenableBuilder<bool>(
                            key: ValueKey('vocab_$tappedWord'),
                            valueListenable: isCurrentWordSaved,
                            builder: (_, isSaved, _) => VocabHighlight(
                              word: tappedWord!,
                              isSaved: isSaved,
                              onToggle: onVocabToggle,
                              onDismiss: onVocabDismiss,
                              extraBottomPadding:
                                  readingControlsBarApproxHeight(context),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('vocab_empty'),
                          ),
                  ),
                ),

                // ── Player controls — pinned at bottom, on top of vocab bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ReadingControls(
                    state: state,
                    onPlayPause: onPlayPause,
                    onSpeedDecrease: onSpeedDecrease,
                    onSpeedIncrease: onSpeedIncrease,
                    onFontSizeDecrease: onFontSizeDecrease,
                    onFontSizeIncrease: onFontSizeIncrease,
                    canDecreaseFontSize:
                        (prefs?.fontSize ?? AppConstants.minFontSize) >
                        AppConstants.minFontSize,
                    canIncreaseFontSize:
                        (prefs?.fontSize ?? AppConstants.maxFontSize) <
                        AppConstants.maxFontSize,
                    onSeek: onSeek,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Color _resolveFadeBg(bool isDark, String preset) =>
      AppColors.resolveReadingColor(
        isDark,
        preset,
        AppColors.lightSurface,
        AppColors.surface,
      );
}
