import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/services/tts_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';

/// Speaker icon that pronounces [word] via TTS and highlights while active.
class TtsSpeakerButton extends StatelessWidget {
  final String word;

  const TtsSpeakerButton({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final ttsService = getIt<TtsService>();

    return StreamBuilder<String?>(
      stream: ttsService.currentWord$,
      builder: (context, snap) {
        final isThisWordPlaying = snap.data == word;
        return GestureDetector(
          onTap: () => ttsService.speak(word),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: Icon(
              isThisWordPlaying
                  ? Icons.volume_up_rounded
                  : Icons.volume_up_outlined,
              size: 20,
              color: isThisWordPlaying ? primary : onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
