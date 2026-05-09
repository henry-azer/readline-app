import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readline_app/core/theme/app_gradients.dart';

class SplashBookMark extends StatelessWidget {
  const SplashBookMark({
    super.key,
    required this.fade,
    required this.scale,
    required this.wave,
    required this.isDark,
  });

  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<double> wave;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedBuilder(
          animation: wave,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, wave.value),
              child: child,
            );
          },
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppGradients.primary(isDark).createShader(bounds),
            blendMode: BlendMode.srcIn,
            // Custom asset (rather than `Icons.auto_stories_rounded`) so the
            // left page renders solid — matching the iOS LaunchSplash PNG.
            child: SvgPicture.asset(
              'assets/branding/book_mark.svg',
              width: 80,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
