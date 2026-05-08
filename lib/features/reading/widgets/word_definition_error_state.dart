import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/dictionary_service.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class WordDefinitionErrorState extends StatelessWidget {
  final DictionaryError error;
  final Color onSurfaceVariant;

  const WordDefinitionErrorState({
    super.key,
    required this.error,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      DictionaryError.notFound => AppStrings.dictNotFound.tr,
      DictionaryError.noInternet => AppStrings.dictNoInternet.tr,
      DictionaryError.timeout => AppStrings.dictTimeout.tr,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        message,
        style: AppTypography.wordDefErrorMessage.copyWith(
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
