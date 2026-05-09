import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Italic block quote of the sentence in which a vocabulary word appeared,
/// with the saved word highlighted in the primary tone.
class WordCardContextQuote extends StatelessWidget {
  final String sentence;
  final String word;
  final bool isDark;

  const WordCardContextQuote({
    super.key,
    required this.sentence,
    required this.word,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final textColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final lower = sentence.toLowerCase();
    final wordLower = word.toLowerCase();
    final idx = lower.indexOf(wordLower);

    final baseStyle = AppTypography.bodySmall.copyWith(
      color: textColor,
      fontStyle: FontStyle.italic,
    );

    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: primary.withValues(alpha: 0.4), width: 2),
        ),
      ),
      child: idx == -1
          ? Text(
              AppStrings.generalQuoted.trParams({'text': sentence}),
              style: baseStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: '"${sentence.substring(0, idx)}'),
                  TextSpan(
                    text: sentence.substring(idx, idx + word.length),
                    style: baseStyle.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: '${sentence.substring(idx + word.length)}"'),
                ],
              ),
            ),
    );
  }
}
