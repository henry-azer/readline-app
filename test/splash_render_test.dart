// Renders the actual SplashScreen widget into PNG launch-splash assets so
// the iOS launch screen is pixel-equivalent to what the app shows on splash.
//
// Run with:  flutter test test/splash_render_test.dart
// Output:    ios/Runner/Assets.xcassets/LaunchSplash.imageset/launch_splash_*.png

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';

const String _outDir = 'ios/Runner/Assets.xcassets/LaunchSplash.imageset';
const double _logicalWidth = 240;
const double _logicalHeight = 184;

Widget _splashContent({required bool isDark}) {
  final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
  final onSurfaceVariant = isDark
      ? AppColors.onSurfaceVariant
      : AppColors.lightOnSurfaceVariant;
  final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

  return ColoredBox(
    color: bgColor,
    child: Center(
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
            style: AppTypography.splashTagline.copyWith(color: onSurfaceVariant),
          ),
        ],
      ),
    ),
  );
}

Future<void> _renderAndWrite(
  WidgetTester tester, {
  required bool isDark,
  required double pixelRatio,
  required String filename,
}) async {
  final repaintKey = GlobalKey();

  tester.view.physicalSize = Size(
    _logicalWidth * pixelRatio,
    _logicalHeight * pixelRatio,
  );
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(
          platformBrightness:
              isDark ? Brightness.dark : Brightness.light,
          size: const Size(_logicalWidth, _logicalHeight),
          devicePixelRatio: pixelRatio,
        ),
        child: RepaintBoundary(
          key: repaintKey,
          child: SizedBox(
            width: _logicalWidth,
            height: _logicalHeight,
            child: _splashContent(isDark: isDark),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary = repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final ByteData? bytes =
      await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_outDir/$filename').writeAsBytesSync(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('wrote $filename (${image.width}×${image.height})');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final newsreaderBytes = await File(
      'tools/branding/fonts/Newsreader-ExtraBoldItalic.ttf',
    ).readAsBytes();
    final interBytes = await File(
      'tools/branding/fonts/Inter-SemiBold.ttf',
    ).readAsBytes();

    Future<void> register(String family, Uint8List bytes) async {
      final loader = FontLoader(family);
      loader.addFont(
        Future<ByteData>.value(ByteData.view(bytes.buffer)),
      );
      await loader.load();
    }

    // Register under multiple aliases google_fonts may query.
    await register('Newsreader', newsreaderBytes);
    await register('Newsreader_w800italic', newsreaderBytes);
    await register('Inter', interBytes);
    await register('Inter_w600', interBytes);
  });

  testWidgets('render light @2x', (t) => _renderAndWrite(
        t,
        isDark: false,
        pixelRatio: 2.0,
        filename: 'launch_splash_light@2x.png',
      ));

  testWidgets('render light @3x', (t) => _renderAndWrite(
        t,
        isDark: false,
        pixelRatio: 3.0,
        filename: 'launch_splash_light@3x.png',
      ));

  testWidgets('render dark @2x', (t) => _renderAndWrite(
        t,
        isDark: true,
        pixelRatio: 2.0,
        filename: 'launch_splash_dark@2x.png',
      ));

  testWidgets('render dark @3x', (t) => _renderAndWrite(
        t,
        isDark: true,
        pixelRatio: 3.0,
        filename: 'launch_splash_dark@3x.png',
      ));
}
