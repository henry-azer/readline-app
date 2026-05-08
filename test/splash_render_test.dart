// Renders the actual SplashScreen widget into PNG launch-splash assets so
// the iOS launch screen is pixel-equivalent to what the app shows on splash.
//
// Run with:  flutter test test/splash_render_test.dart
//
// Output: writes launch_splash_{light,dark}@{2x,3x}.png directly into
// ios/Runner/Assets.xcassets/LaunchSplash.imageset/

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';

const String _outDir =
    'ios/Runner/Assets.xcassets/LaunchSplash.imageset';

// Splash content area (logical points). Matches the SplashScreen Column.
const double _logicalWidth = 240;
const double _logicalHeight = 184;

Future<void> _loadFont(String family, String path) async {
  final ByteData data = await rootBundle.load(path);
  final loader = FontLoader(family);
  loader.addFont(Future<ByteData>.value(data));
  await loader.load();
}

class _StaticSplash extends StatelessWidget {
  const _StaticSplash({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppGradients.primary(isDark).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Icon(Icons.auto_stories_rounded, size: 80),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'READ-IT',
                style: AppTypography.splashBrand.copyWith(color: primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'READ AT YOUR PACE',
                style: AppTypography.splashTagline
                    .copyWith(color: onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _renderSplash({
  required bool isDark,
  required double pixelRatio,
  required String outPath,
}) async {
  await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
    // Provide a background-only host; the actual content goes inside
    // a RepaintBoundary sized to logical splash dimensions so the
    // exported PNG only contains the splash content.
  });
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Don't try to fetch fonts over network during tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Pre-load Newsreader (ExtraBold Italic, weight 800) and Inter (SemiBold,
  // weight 600) from the project's branding fonts. These are bundled via
  // tools/branding/fonts/ for offline rendering of the static launch image.
  setUpAll(() async {
    final newsreaderBytes = await File(
      'tools/branding/fonts/Newsreader-ExtraBoldItalic.ttf',
    ).readAsBytes();
    final interBytes = await File(
      'tools/branding/fonts/Inter-SemiBold.ttf',
    ).readAsBytes();

    // Register the fonts under all the family names google_fonts might query.
    for (final family in const ['Newsreader', 'Newsreader_italic']) {
      final loader = FontLoader(family);
      loader.addFont(
        Future<ByteData>.value(ByteData.view(newsreaderBytes.buffer)),
      );
      await loader.load();
    }
    for (final family in const ['Inter', 'Inter_regular']) {
      final loader = FontLoader(family);
      loader.addFont(
        Future<ByteData>.value(ByteData.view(interBytes.buffer)),
      );
      await loader.load();
    }
  });

  Future<void> capture({
    required bool isDark,
    required double pixelRatio,
    required String filename,
  }) async {
    await testWidgets('render $filename', (tester) async {
      final repaintKey = GlobalKey();
      final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

      tester.view.physicalSize = Size(
        _logicalWidth * pixelRatio,
        _logicalHeight * pixelRatio,
      );
      tester.view.devicePixelRatio = pixelRatio;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(
              platformBrightness: isDark ? Brightness.dark : Brightness.light,
              size: const Size(_logicalWidth, _logicalHeight),
              devicePixelRatio: pixelRatio,
            ),
            child: RepaintBoundary(
              key: repaintKey,
              child: SizedBox(
                width: _logicalWidth,
                height: _logicalHeight,
                child: ColoredBox(
                  color: bgColor,
                  child: _StaticSplash(isDark: isDark),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final boundary = repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      File('$_outDir/$filename').writeAsBytesSync(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('wrote $filename (${image.width}×${image.height})');
    });
  }

  await capture(isDark: false, pixelRatio: 2.0, filename: 'launch_splash_light@2x.png');
  await capture(isDark: false, pixelRatio: 3.0, filename: 'launch_splash_light@3x.png');
  await capture(isDark: true,  pixelRatio: 2.0, filename: 'launch_splash_dark@2x.png');
  await capture(isDark: true,  pixelRatio: 3.0, filename: 'launch_splash_dark@3x.png');
}
