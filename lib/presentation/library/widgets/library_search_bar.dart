import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';

class LibrarySearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String initialQuery;
  final String? hintText;

  const LibrarySearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.initialQuery = '',
    this.hintText,
  });

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final fillColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final hintColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: AppTypography.bodyMedium.copyWith(color: textColor),
        decoration: InputDecoration(
          hintText: widget.hintText ?? AppStrings.librarySearchHint.tr,
          hintStyle: AppTypography.bodyMedium.copyWith(color: hintColor),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: hintColor),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: hintColor),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                  },
                )
              : null,
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: AppRadius.fullBorder,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.fullBorder,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.fullBorder,
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smd,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
