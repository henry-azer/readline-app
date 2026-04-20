import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/presentation/shell/widgets/read_it_nav_bar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      body: navigationShell,
      bottomNavigationBar: ReadItNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
