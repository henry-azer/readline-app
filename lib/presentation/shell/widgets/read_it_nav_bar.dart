import 'package:flutter/material.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/services/haptic_service.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

/// Height of the nav bar content area (excluding safe area).
const kNavBarContentHeight = 64.0;

/// Size of the center floating button.
const _centerButtonSize = 56.0;

/// How far the center button rises above the bar's curved top.
const _centerButtonOverlap = 22.0;

/// Radius of the concave notch curve.
const _notchRadius = 38.0;

/// Extra gap between the button and the notch edge.
const _notchMargin = 6.0;

/// Width of the center notch spacer.
const _notchSpacerWidth = _notchRadius * 2 + _notchMargin * 2;

/// Sliding indicator dimensions.
const _indicatorWidth = 24.0;
const _indicatorHeight = 3.0;

class ReadItNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const ReadItNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  static const _leftItems = [
    (icon: Icons.home_rounded, key: AppStrings.navHome),
    (icon: Icons.library_books_rounded, key: AppStrings.navLibrary),
  ];

  static const _rightItems = [
    (icon: Icons.insights_rounded, key: AppStrings.navAnalytics),
    (icon: Icons.settings_rounded, key: AppStrings.navSettings),
  ];

  /// Compute the center-x of each tab slot given the total bar width.
  /// Layout: [Expanded][Expanded][_notchSpacerWidth][Expanded][Expanded]
  /// The 4 Expanded slots share (barWidth - spacer) equally.
  double _tabCenterX(int index, double barWidth) {
    final tabWidth = (barWidth - _notchSpacerWidth) / 4;
    if (index < 2) {
      // Left tabs: slot 0 and 1
      return tabWidth * index + tabWidth / 2;
    } else {
      // Right tabs: slot 2 and 3, offset by spacer
      final rightIndex = index - 2;
      return tabWidth * 2 + _notchSpacerWidth + tabWidth * rightIndex + tabWidth / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLowest;
    final activeColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final inactiveColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final borderColor = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final totalHeight = kNavBarContentHeight + bottomPadding + _centerButtonOverlap;

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final indicatorLeft =
              _tabCenterX(currentIndex, barWidth) - _indicatorWidth / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Curved bar background ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _CurvedNavBarPainter(
                    color: bgColor,
                    borderColor:
                        borderColor.withValues(alpha: isDark ? 0.15 : 0.3),
                    notchRadius: _notchRadius,
                    notchMargin: _notchMargin,
                    topOffset: _centerButtonOverlap,
                    bottomPadding: bottomPadding,
                  ),
                ),
              ),

              // ── Sliding active indicator ──
              AnimatedPositioned(
                duration: AppDurations.calm,
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                bottom: bottomPadding + AppSpacing.xs,
                child: Container(
                  width: _indicatorWidth,
                  height: _indicatorHeight,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
              ),

              // ── Nav items row ──
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPadding,
                height: kNavBarContentHeight,
                child: Row(
                  children: [
                    // Left tabs
                    ..._leftItems.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      return Expanded(
                        child: _NavItem(
                          icon: item.icon,
                          label: item.key.tr,
                          isActive: currentIndex == i,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () {
                            getIt<HapticService>().selection();
                            onTap(i);
                          },
                        ),
                      );
                    }),

                    // Center spacer for the notch
                    const SizedBox(width: _notchSpacerWidth),

                    // Right tabs
                    ..._rightItems.asMap().entries.map((e) {
                      final i = e.key + _leftItems.length;
                      final item = e.value;
                      return Expanded(
                        child: _NavItem(
                          icon: item.icon,
                          label: item.key.tr,
                          isActive: currentIndex == i,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () {
                            getIt<HapticService>().selection();
                            onTap(i);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // ── Floating center button ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _CenterAddButton(
                    onTap: onAddTap,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Curved bar painter ───────────────────────────────────────────────────────

class _CurvedNavBarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double notchRadius;
  final double notchMargin;
  final double topOffset;
  final double bottomPadding;

  _CurvedNavBarPainter({
    required this.color,
    required this.borderColor,
    required this.notchRadius,
    required this.notchMargin,
    required this.topOffset,
    required this.bottomPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final barTop = topOffset;
    final r = notchRadius + notchMargin;

    final path = Path()
      ..moveTo(0, barTop)
      ..lineTo(cx - r - r * 0.6, barTop)
      ..cubicTo(
        cx - r, barTop,
        cx - r * 0.52, barTop + r * 0.85,
        cx, barTop + r * 0.85,
      )
      ..cubicTo(
        cx + r * 0.52, barTop + r * 0.85,
        cx + r, barTop,
        cx + r + r * 0.6, barTop,
      )
      ..lineTo(w, barTop)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    final borderPath = Path()
      ..moveTo(0, barTop)
      ..lineTo(cx - r - r * 0.6, barTop)
      ..cubicTo(
        cx - r, barTop,
        cx - r * 0.52, barTop + r * 0.85,
        cx, barTop + r * 0.85,
      )
      ..cubicTo(
        cx + r * 0.52, barTop + r * 0.85,
        cx + r, barTop,
        cx + r + r * 0.6, barTop,
      )
      ..lineTo(w, barTop);

    canvas.drawPath(
      borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _CurvedNavBarPainter old) =>
      old.color != color || old.borderColor != borderColor;
}

// ── Center floating add button ───────────────────────────────────────────────

class _CenterAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CenterAddButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return TapScale(
      onTap: () {
        getIt<HapticService>().light();
        onTap();
      },
      child: Container(
        width: _centerButtonSize,
        height: _centerButtonSize,
        decoration: BoxDecoration(
          gradient: AppGradients.primary(isDark),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 28,
          color: AppColors.white,
        ),
      ),
    );
  }
}

// ── Nav item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: kNavBarContentHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            // Reserve space for the sliding indicator
            const SizedBox(height: _indicatorHeight + AppSpacing.xxs),
          ],
        ),
      ),
    );
  }
}
