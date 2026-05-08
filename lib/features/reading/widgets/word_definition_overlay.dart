import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/reading/viewmodels/word_definition_viewmodel.dart';
import 'package:readline_app/features/reading/widgets/word_definition_body.dart';
import 'package:readline_app/features/reading/widgets/word_definition_error_state.dart';
import 'package:readline_app/features/reading/widgets/word_definition_loading_state.dart';
import 'package:readline_app/features/reading/widgets/word_definition_save_button.dart';
import 'package:readline_app/widgets/glass_container.dart';

/// Floating word-definition overlay that anchors near the tap position. Owned
/// by the reading screen via [showWordDefinitionPopup] in
/// `word_definition_popup.dart`. UI-only — all dictionary, TTS and vocabulary
/// state lives in [WordDefinitionViewModel].
class WordDefinitionOverlay extends StatefulWidget {
  final String word;
  final Offset tapPosition;
  final String sourceDocumentId;
  final String sourceDocumentTitle;
  final String contextSentence;
  final VoidCallback onDismiss;
  final VoidCallback? onCloseStarted;
  final VoidCallback? onSaved;
  final ValueListenable<bool>? savedListener;
  final VoidCallback? onToggle;
  final double bottomReserve;

  const WordDefinitionOverlay({
    super.key,
    required this.word,
    required this.tapPosition,
    required this.sourceDocumentId,
    required this.sourceDocumentTitle,
    required this.contextSentence,
    required this.onDismiss,
    this.onCloseStarted,
    this.onSaved,
    this.savedListener,
    this.onToggle,
    this.bottomReserve = 0,
  });

  @override
  State<WordDefinitionOverlay> createState() => _WordDefinitionOverlayState();
}

class _WordDefinitionOverlayState extends State<WordDefinitionOverlay>
    with SingleTickerProviderStateMixin {
  late final WordDefinitionViewModel _viewModel;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = WordDefinitionViewModel(
      word: widget.word,
      sourceDocumentId: widget.sourceDocumentId,
      sourceDocumentTitle: widget.sourceDocumentTitle,
      contextSentence: widget.contextSentence,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _viewModel.init();
    if (widget.savedListener != null) {
      _viewModel.setSavedFromExternal(widget.savedListener!.value);
      widget.savedListener!.addListener(_onSavedListenerChanged);
    } else {
      _viewModel.loadInitialSavedState();
    }
  }

  void _onSavedListenerChanged() {
    if (!mounted) return;
    _viewModel.setSavedFromExternal(widget.savedListener!.value);
  }

  @override
  void dispose() {
    widget.savedListener?.removeListener(_onSavedListenerChanged);
    _fadeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleToggleTap() async {
    if (widget.onToggle != null) {
      // Parent owns the saved-state notifier — let it perform the work and
      // it will push the new value back via the listener.
      widget.onToggle!.call();
      return;
    }
    final wasSaved = _viewModel.isWordSaved$.value;
    final nowSaved = await _viewModel.toggleSaved();
    if (!wasSaved && nowSaved) widget.onSaved?.call();
  }

  Future<void> _dismiss() async {
    widget.onCloseStarted?.call();
    await _fadeController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final screenSize = MediaQuery.sizeOf(context);

    // Position popup near tap but constrain to screen
    const popupWidth = 300.0;
    const popupMaxHeight = 320.0;

    double left = widget.tapPosition.dx - popupWidth / 2;
    left = left.clamp(
      AppSpacing.md,
      screenSize.width - popupWidth - AppSpacing.md,
    );

    final spaceBelow = screenSize.height - widget.tapPosition.dy;
    final showAbove = spaceBelow < popupMaxHeight + 80;
    double top;
    if (showAbove) {
      top = widget.tapPosition.dy - popupMaxHeight - AppSpacing.md;
      top = top.clamp(AppSpacing.xxxxl, screenSize.height - popupMaxHeight);
    } else {
      top = widget.tapPosition.dy + AppSpacing.md;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Tap-outside dismiss — bounded so the bar / controls strip
          // continues to receive taps.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: widget.bottomReserve,
            child: GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: popupWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    (screenSize.height - top - widget.bottomReserve)
                        .clamp(0.0, double.infinity),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: GlassContainer(
                  borderRadius: AppRadius.lgBorder,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  backgroundColor: (isDark
                          ? AppColors.surfaceContainerHigh
                          : AppColors.lightSurfaceContainerLowest)
                      .withValues(alpha: 0.92),
                  child: SingleChildScrollView(child: _buildContent(isDark)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return StreamBuilder<WordDefinitionUiState>(
      stream: _viewModel.uiState$,
      builder: (context, uiSnap) {
        final ui = uiSnap.data ??
            (isLoading: true, definition: null, error: null);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.word,
                        style: AppTypography.titleLarge.copyWith(
                          color: onSurface,
                        ),
                      ),
                      if (ui.definition?.phonetic != null) ...[
                        const SizedBox(height: AppSpacing.micro),
                        Text(
                          ui.definition!.phonetic!,
                          style: AppTypography.bodySmall.copyWith(
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _viewModel.isTtsAvailable$,
                  builder: (context, ttsSnap) {
                    if (ttsSnap.data != true) return const SizedBox.shrink();
                    return StreamBuilder<bool>(
                      stream: _viewModel.ttsPlaying$,
                      builder: (context, playingSnap) {
                        final playing = playingSnap.data ?? false;
                        return GestureDetector(
                          onTap: _viewModel.speak,
                          child: AnimatedContainer(
                            duration: AppDurations.short,
                            padding: const EdgeInsets.all(AppSpacing.xxs),
                            child: Icon(
                              playing
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_up_outlined,
                              size: 20,
                              color: playing ? primary : onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.xxs),
                GestureDetector(
                  onTap: _dismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            if (ui.isLoading)
              WordDefinitionLoadingState(primary: primary)
            else ...[
              if (ui.error != null)
                WordDefinitionErrorState(
                  error: ui.error!,
                  onSurfaceVariant: onSurfaceVariant,
                )
              else if (ui.definition != null)
                WordDefinitionBody(
                  definition: ui.definition!,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  primary: primary,
                ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<bool>(
                stream: _viewModel.isWordSaved$,
                builder: (context, savedSnap) {
                  return WordDefinitionSaveButton(
                    isWordSaved: savedSnap.data ?? false,
                    onToggle: _handleToggleTap,
                    isDark: isDark,
                    primary: primary,
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
