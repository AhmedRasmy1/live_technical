import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/styles_manager.dart';

/// Rounded search field with a search icon.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.onChanged,
    this.hint = 'Search',
    this.fillColor,
  });

  final ValueChanged<String>? onChanged;
  final String hint;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.buttonHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor ?? context.colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: getRegularStyle(fontSize: AppConstants.bodySize),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: context.colors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: AppConstants.iconSize,
            color: context.colors.textPrimary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
          ),
        ),
      ),
    );
  }
}
