import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/shell/widgets/curved_nav_bar_painter.dart';
import 'package:readline_app/features/shell/widgets/nav_center_add_button.dart';
import 'package:readline_app/features/shell/widgets/nav_item.dart';

const kNavBarContentHeight = 64.0;
const _centerButtonOverlap = 22.0;
const _notchRadius = 38.0;
const _notchMargin = 6.0;
const _notchSpacerWidth = _notchRadius * 2 + _notchMargin * 2;
const _indicatorWidth = 24.0;
const _indicatorHeight = 3.0;

class ReadlineNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const ReadlineNavBar({
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
    (icon: Icons.spellcheck_rounded, key: AppStrings.navVocab),
    (icon: Icons.settings_rounded, key: AppStrings.navSettings),
  ];

  /// Compute the center-x of each tab slot given the total bar width.
  /// Layout: [Expanded][Expanded][_notchSpacerWidth][Expanded][Expanded]
  double _tabCenterX(int index, double barWidth) {
    final tabWidth = (barWidth - _notchSpacerWidth) / 4;
    if (index < 2) {
      return tabWidth * index + tabWidth / 2;
    } else {
      final rightIndex = index - 2;
      return tabWidth * 2 +
          _notchSpacerWidth +
          tabWidth * rightIndex +
          tabWidth / 2;
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
    final totalHeight =
        kNavBarContentHeight + bottomPadding + _centerButtonOverlap;
    final indicatorBottomReserve = _indicatorHeight + AppSpacing.xxs;

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
              Positioned.fill(
                child: CustomPaint(
                  painter: CurvedNavBarPainter(
                    color: bgColor,
                    borderColor: borderColor.withValues(
                      alpha: isDark ? 0.15 : 0.3,
                    ),
                    notchRadius: _notchRadius,
                    notchMargin: _notchMargin,
                    topOffset: _centerButtonOverlap,
                    bottomPadding: bottomPadding,
                  ),
                ),
              ),

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

              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPadding,
                height: kNavBarContentHeight,
                child: Row(
                  children: [
                    ..._leftItems.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      return Expanded(
                        child: NavItem(
                          icon: item.icon,
                          label: item.key.tr,
                          isActive: currentIndex == i,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onTap(i),
                          height: kNavBarContentHeight,
                          bottomReserve: indicatorBottomReserve,
                        ),
                      );
                    }),

                    const SizedBox(width: _notchSpacerWidth),

                    ..._rightItems.asMap().entries.map((e) {
                      final i = e.key + _leftItems.length;
                      final item = e.value;
                      return Expanded(
                        child: NavItem(
                          icon: item.icon,
                          label: item.key.tr,
                          isActive: currentIndex == i,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onTap(i),
                          height: kNavBarContentHeight,
                          bottomReserve: indicatorBottomReserve,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: NavCenterAddButton(onTap: onAddTap, isDark: isDark),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
