import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Debounced search bar for vocabulary list.
class VocabularySearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const VocabularySearchBar({super.key, required this.onChanged});

  @override
  State<VocabularySearchBar> createState() => _VocabularySearchBarState();
}

class _VocabularySearchBarState extends State<VocabularySearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.mdBorder,
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: AppTypography.bodyMedium.copyWith(color: onSurface),
        decoration: InputDecoration(
          hintText: AppStrings.vocabSearchHint.tr,
          hintStyle: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: onSurfaceVariant,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: onSurfaceVariant,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
        ),
      ),
    );
  }
}
