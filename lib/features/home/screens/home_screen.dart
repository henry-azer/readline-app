import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/app.dart'
    show
        libraryChangeNotifier,
        preferencesChangeNotifier,
        sessionChangeNotifier;
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:readline_app/features/home/widgets/home_body.dart';
import 'package:readline_app/features/home/widgets/home_loading_skeleton.dart';
import 'package:readline_app/features/home/widgets/import_content_sheet.dart';
import 'package:readline_app/widgets/brand_mark.dart';
import 'package:readline_app/widgets/celebration_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late final AnimationController _staggerController;
  StreamSubscription<CelebrationData?>? _celebrationSub;
  bool _hasAnimated = false;
  // Guards back-to-back celebrations (e.g. streak listener + post-session
  // words-milestone fire in the same tick). The queue holds anything that
  // arrives while an overlay is open so it can be drained on dismiss
  // instead of stacking on top of the current one.
  bool _celebrationOpen = false;
  final List<CelebrationData> _celebrationQueue = [];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: AppDurations.stagger,
    );
    _viewModel = HomeViewModel();
    libraryChangeNotifier.addListener(_onLibraryChanged);
    sessionChangeNotifier.addListener(_onSessionChanged);
    preferencesChangeNotifier.addListener(_onPreferencesChanged);
    _celebrationSub = _viewModel.pendingCelebration$.listen((celebration) {
      if (celebration == null || !mounted) return;
      if (_celebrationOpen) {
        _celebrationQueue.add(celebration);
      } else {
        _showCelebration(celebration);
      }
    });
    _viewModel.init();
  }

  void _showCelebration(CelebrationData celebration) {
    _celebrationOpen = true;
    Navigator.of(context)
        .push(
          PageRouteBuilder<void>(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (_, _, _) => CelebrationOverlay(
              celebration: celebration,
              onContinue: () {
                _viewModel.clearPendingCelebration();
                Navigator.of(context).pop();
              },
            ),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: AppDurations.calm,
            reverseTransitionDuration: AppDurations.normal,
          ),
        )
        .whenComplete(() {
          _celebrationOpen = false;
          if (_celebrationQueue.isNotEmpty && mounted) {
            _showCelebration(_celebrationQueue.removeAt(0));
          }
        });
  }

  void _onLibraryChanged() => _viewModel.refresh();

  // Reading session saved → refresh stats so streak / total-words / today
  // minutes reflect the latest activity AND so the home shelf shows the
  // updated featured doc.
  void _onSessionChanged() => _viewModel.refresh();

  // WPM / daily-goal / userName changed elsewhere — re-refresh so the
  // featured-card minutes estimate, target chip, and greeting line stay
  // in sync without needing a hot reload.
  void _onPreferencesChanged() => _viewModel.refresh();

  @override
  void dispose() {
    _celebrationSub?.cancel();
    libraryChangeNotifier.removeListener(_onLibraryChanged);
    sessionChangeNotifier.removeListener(_onSessionChanged);
    preferencesChangeNotifier.removeListener(_onPreferencesChanged);
    _staggerController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // Single canonical entry point so the home "Get Started" CTA and the
  // shell's center "+" button behave identically.
  void _showImportSheet() => ImportContentSheet.show(context);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.xl,
        title: const BrandMark(),
        centerTitle: false,
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, 0.4),
                  colors: [AppColors.homeGradientTop, AppColors.surface],
                ),
              )
            : null,
        child: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          builder: (context, loadingSnap) {
            final isLoading = loadingSnap.data ?? true;

            if (isLoading) {
              return HomeLoadingSkeleton(isDark: isDark);
            }

            if (!_hasAnimated) {
              _hasAnimated = true;
              _staggerController.forward();
            }

            return RefreshIndicator(
              color: isDark ? AppColors.primary : AppColors.lightPrimary,
              onRefresh: _viewModel.refresh,
              child: HomeBody(
                viewModel: _viewModel,
                onImport: _showImportSheet,
                staggerController: _staggerController,
              ),
            );
          },
        ),
      ),
    );
  }
}

