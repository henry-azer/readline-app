import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/presentation/home/widgets/import_content_sheet.dart';
import 'package:read_it/presentation/shell/widgets/read_it_nav_bar.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tabAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabAnimation = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _tabAnimation,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tabAnimation,
      curve: Curves.easeOutCubic,
    ));

    // Start fully visible
    _tabAnimation.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != _previousIndex) {
      _previousIndex = newIndex;
      // Quick fade out then fade in
      _tabAnimation.value = 0.0;
      _tabAnimation.forward();
    }
  }

  @override
  void dispose() {
    _tabAnimation.dispose();
    super.dispose();
  }

  void _showImportSheet() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.barrierOverlay,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => const ImportContentSheet(),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: AppDurations.smooth,
        reverseTransitionDuration: AppDurations.calm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: ReadItNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onAddTap: _showImportSheet,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
