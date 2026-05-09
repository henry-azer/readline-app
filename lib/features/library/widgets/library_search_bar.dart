import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class LibrarySearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String initialQuery;
  final String? hintText;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  const LibrarySearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.initialQuery = '',
    this.hintText,
    this.focusNode,
    this.onTap,
  });

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  late final TextEditingController _controller;
  // Internal fallback when the parent doesn't pass a FocusNode — keeps the
  // hasFocus state observable here so the X icon can react to focus changes.
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant LibrarySearchBar old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      old.focusNode?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _internalFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
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

    final showClear = _focusNode.hasFocus || _controller.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        style: AppTypography.bodyMedium.copyWith(color: textColor),
        decoration: InputDecoration(
          hintText: widget.hintText ?? AppStrings.librarySearchHint.tr,
          hintStyle: AppTypography.bodyMedium.copyWith(color: hintColor),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: hintColor),
          suffixIcon: showClear
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: hintColor),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _controller.clear();
                      widget.onClear();
                    }
                    _focusNode.unfocus();
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
