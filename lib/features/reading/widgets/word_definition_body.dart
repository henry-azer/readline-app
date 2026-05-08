import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/word_definition_model.dart';

class WordDefinitionBody extends StatelessWidget {
  final WordDefinitionModel definition;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;

  const WordDefinitionBody({
    super.key,
    required this.definition,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (definition.partOfSpeech.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sxs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smBorder,
            ),
            child: Text(
              definition.partOfSpeech,
              style: AppTypography.wordDefBadge.copyWith(color: primary),
            ),
          ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          definition.definition,
          style: AppTypography.bodyMedium.copyWith(color: onSurface),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),

        if (definition.exampleSentence != null &&
            definition.exampleSentence!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.only(left: AppSpacing.smd),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: primary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              '"${definition.exampleSentence!}"',
              style: AppTypography.wordDefExample.copyWith(
                color: onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
