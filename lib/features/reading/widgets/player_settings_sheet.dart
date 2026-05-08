import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';
import 'package:readline_app/features/reading/widgets/display_settings_tab.dart';
import 'package:readline_app/features/reading/widgets/speed_settings_tab.dart';
import 'package:readline_app/features/reading/widgets/theme_settings_tab.dart';

class PlayerSettingsSheet extends StatefulWidget {
  final UserPreferencesModel prefs;
  final ValueChanged<int> onSpeedChanged;
  final ValueChanged<int> onFontSizeChanged;
  final ValueChanged<double> onLineSpacingChanged;
  final ValueChanged<int> onFocusLinesChanged;
  final ValueChanged<String> onFontFamilyChanged;
  final VoidCallback onVocabToggled;
  final ValueChanged<String> onTextAlignmentChanged;
  final VoidCallback onAutoPlayToggled;
  final ValueChanged<String> onBackgroundChanged;
  final ValueChanged<double> onMarginChanged;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onDimChanged;
  final ValueChanged<String> onFontColorChanged;
  final VoidCallback onBoldToggled;
  final VoidCallback onItalicToggled;
  final VoidCallback onUnderlineToggled;
  final ValueChanged<String> onLetterSpacingChanged;
  final ValueChanged<String> onReadingThemeChanged;

  const PlayerSettingsSheet({
    super.key,
    required this.prefs,
    required this.onSpeedChanged,
    required this.onFontSizeChanged,
    required this.onLineSpacingChanged,
    required this.onFocusLinesChanged,
    required this.onFontFamilyChanged,
    required this.onVocabToggled,
    required this.onTextAlignmentChanged,
    required this.onAutoPlayToggled,
    required this.onBackgroundChanged,
    required this.onMarginChanged,
    required this.onBrightnessChanged,
    required this.onDimChanged,
    required this.onFontColorChanged,
    required this.onBoldToggled,
    required this.onItalicToggled,
    required this.onUnderlineToggled,
    required this.onLetterSpacingChanged,
    required this.onReadingThemeChanged,
  });

  @override
  State<PlayerSettingsSheet> createState() => _PlayerSettingsSheetState();
}

class _PlayerSettingsSheetState extends State<PlayerSettingsSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _speed;
  late int _fontSize;
  late double _lineSpacing;
  late String _fontFamily;
  late String _letterSpacing;
  late String _readingTheme;
  late String _textAlignment;
  late double _margin;
  late bool _isBold;
  late bool _isItalic;
  late bool _isUnderline;
  late double _brightness;
  late double _dim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final p = widget.prefs;
    _speed = p.readingSpeedWpm;
    _fontSize = p.fontSize;
    _lineSpacing = p.lineSpacing;
    _fontFamily = p.fontFamily;
    _letterSpacing = p.letterSpacing;
    _readingTheme = p.readingTheme;
    _textAlignment = p.textAlignment;
    _margin = p.readingMargin;
    _isBold = p.readingBold;
    _isItalic = p.readingItalic;
    _isUnderline = p.readingUnderline;
    _brightness = p.brightnessLevel;
    _dim = p.brightnessOverlay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    // Use the same base surface as the home / import-document screens so
    // the player settings sheet feels like part of the same surface stack.
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final trackColor = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHigh;
    final dividerColor = isDark
        ? AppColors.outlineVariant.withValues(alpha: 0.2)
        : AppColors.lightOutlineVariant.withValues(alpha: 0.3);

    final sliderTheme = SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: trackColor,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.12),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.playerSettingsTitle.tr,
          style: AppTypography.titleMedium.copyWith(color: onSurface),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          indicatorWeight: 2,
          labelColor: primary,
          unselectedLabelColor: onSurfaceVariant,
          labelStyle: AppTypography.readingTabLabel,
          unselectedLabelStyle: AppTypography.readingTabLabel,
          dividerColor: dividerColor,
          tabs: [
            Tab(text: AppStrings.playerTabDisplay.tr),
            Tab(text: AppStrings.playerTabSpeed.tr),
            Tab(text: AppStrings.playerTabTheme.tr),
          ],
        ),
      ),
      body: SliderTheme(
        data: sliderTheme,
        child: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Display ──────────────────────────────────────
            DisplaySettingsTab(
              fontSize: _fontSize,
              lineSpacing: _lineSpacing,
              fontFamily: _fontFamily,
              letterSpacing: _letterSpacing,
              textAlignment: _textAlignment,
              margin: _margin,
              isBold: _isBold,
              isItalic: _isItalic,
              isUnderline: _isUnderline,
              isDark: isDark,
              primary: primary,
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
              trackColor: trackColor,
              dividerColor: dividerColor,
              onFontSizeChanged: (v) {
                setState(() => _fontSize = v);
                widget.onFontSizeChanged(v);
              },
              onLineSpacingChanged: (v) {
                setState(() => _lineSpacing = v);
                widget.onLineSpacingChanged(v);
              },
              onFontFamilyChanged: (v) {
                setState(() => _fontFamily = v);
                widget.onFontFamilyChanged(v);
              },
              onLetterSpacingChanged: (v) {
                setState(() => _letterSpacing = v);
                widget.onLetterSpacingChanged(v);
              },
              onTextAlignmentChanged: (v) {
                setState(() => _textAlignment = v);
                widget.onTextAlignmentChanged(v);
              },
              onMarginChanged: (v) {
                setState(() => _margin = v);
                widget.onMarginChanged(v);
              },
              onBoldToggled: () {
                setState(() => _isBold = !_isBold);
                widget.onBoldToggled();
              },
              onItalicToggled: () {
                setState(() => _isItalic = !_isItalic);
                widget.onItalicToggled();
              },
              onUnderlineToggled: () {
                setState(() => _isUnderline = !_isUnderline);
                widget.onUnderlineToggled();
              },
            ),

            // ── Tab 2: Speed ────────────────────────────────────────
            SpeedSettingsTab(
              speed: _speed,
              isDark: isDark,
              primary: primary,
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
              trackColor: trackColor,
              onSpeedChanged: (v) {
                setState(() => _speed = v);
                widget.onSpeedChanged(v);
              },
            ),

            // ── Tab 3: Theme ────────────────────────────────────────
            ThemeSettingsTab(
              readingTheme: _readingTheme,
              brightness: _brightness,
              dim: _dim,
              isDark: isDark,
              primary: primary,
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
              trackColor: trackColor,
              onReadingThemeChanged: (v) {
                setState(() => _readingTheme = v);
                widget.onReadingThemeChanged(v);
              },
              onBrightnessChanged: (v) {
                setState(() => _brightness = v);
                widget.onBrightnessChanged(v);
              },
              onDimChanged: (v) {
                setState(() => _dim = v);
                widget.onDimChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
