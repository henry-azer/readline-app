import 'package:flutter/material.dart';
import 'package:readline_app/app.dart' show vocabChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/viewmodels/vocabulary_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_body.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_loading_skeleton.dart';
import 'package:readline_app/widgets/app_snackbar.dart';
import 'package:readline_app/widgets/brand_mark.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late final VocabularyViewModel _viewModel;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = VocabularyViewModel();
    _viewModel.init();
    vocabChangeNotifier.addListener(_onVocabChanged);
  }

  @override
  void dispose() {
    vocabChangeNotifier.removeListener(_onVocabChanged);
    _searchFocusNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onVocabChanged() => _viewModel.refresh();

  void _onSearchFieldTap() => getIt<HapticService>().light();

  Future<void> _handleDelete(VocabularyWordModel word) async {
    final deleted = await _viewModel.softDeleteWord(word.id);
    if (deleted == null || !mounted) return;
    AppSnackbar.info(
      context,
      AppStrings.wordCardDeleted.trParams({'word': word.word}),
      actionLabel: AppStrings.undo.tr,
      onAction: () => _viewModel.restoreWord(deleted),
    );
  }

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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
        },
        child: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          initialData: _viewModel.isLoading$.value,
          builder: (context, loadingSnap) {
            if (loadingSnap.data ?? true) {
              return VocabularyLoadingSkeleton(isDark: isDark);
            }

            return VocabularyBody(
              viewModel: _viewModel,
              onDelete: _handleDelete,
              searchFocusNode: _searchFocusNode,
              onSearchFieldTap: _onSearchFieldTap,
            );
          },
        ),
      ),
    );
  }
}
