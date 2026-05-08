import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/router/app_router.dart' show shellBranchNavigatorKeys;
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/features/home/widgets/import_content_sheet.dart';
import 'package:readline_app/features/shell/widgets/readline_nav_bar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _handleTabTap(int index) {
    getIt<HapticService>().selection();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  // Push the import sheet on the *active branch's* navigator so the bottom
  // nav bar stays visible — matches home Get Started, which pushes from a
  // context already inside its branch's navigator. Falls back to the shell
  // context's nearest navigator if the branch isn't mounted (defensive).
  void _handleAddTap(BuildContext context) {
    final activeBranch =
        shellBranchNavigatorKeys[navigationShell.currentIndex].currentState;
    ImportContentSheet.show(context, navigator: activeBranch);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: ReadlineNavBar(
          currentIndex: navigationShell.currentIndex,
          onAddTap: () => _handleAddTap(context),
          onTap: _handleTabTap,
        ),
      ),
    );
  }
}
