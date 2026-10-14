import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

/// Shared decoration: white fill, no heavy border, red border on error.
/// Pass [hint] for text fields. Dropdowns draw their own hint widget instead.
InputDecoration appInputDecoration({String? hint}) {
  OutlineInputBorder border(Color? color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: AppConstants.errorBorderWidth),
  );

  return InputDecoration(
    filled: true,
    fillColor: ColorManager.white,
    hintText: hint,
    hintStyle: getRegularStyle(
      fontSize: AppConstants.captionSize,
      color: ColorManager.textGrey,
    ),
    errorStyle: getRegularStyle(
      fontSize: AppConstants.captionSize,
      color: ColorManager.error,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppPadding.p16,
      vertical: AppPadding.p16,
    ),
    border: border(null),
    enabledBorder: border(null),
    focusedBorder: border(null),
    errorBorder: border(ColorManager.error),
    focusedErrorBorder: border(ColorManager.error),
  );
}
