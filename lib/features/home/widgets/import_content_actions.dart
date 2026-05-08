import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/home/viewmodels/import_content_viewmodel.dart';
import 'package:readline_app/widgets/readline_button.dart';

class ImportContentActions extends StatelessWidget {
  final ImportContentViewModel viewModel;
  final TextEditingController textController;
  final VoidCallback onSaveAndRead;
  final VoidCallback onSaveToLibrary;

  const ImportContentActions({
    super.key,
    required this.viewModel,
    required this.textController,
    required this.onSaveAndRead,
    required this.onSaveToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: textController,
      builder: (context, _) {
        return StreamBuilder<String?>(
          stream: viewModel.pickedFilePath$,
          builder: (context, _) {
            final hasContent = viewModel.hasContent(textController.text);
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ReadlineButton(
                    label: AppStrings.homeImportSheetStartReading.tr,
                    icon: Icons.play_arrow_rounded,
                    onTap: hasContent ? onSaveAndRead : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: ReadlineButton(
                    label: AppStrings.homeImportSheetSaveToLibrary.tr,
                    isSecondary: true,
                    onTap: hasContent ? onSaveToLibrary : null,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
