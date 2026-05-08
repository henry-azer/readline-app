import 'package:flutter/material.dart';
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
            child: const Icon(Icons.auto_stories_rounded, size: 80),
          ),
        ),
      ),
    );
  }
}
