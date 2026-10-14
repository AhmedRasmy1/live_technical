import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

/// Red snack bar used to report a failed operation or invalid input.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorManager.error,
      content: Text(
        message,
        style: getRegularStyle(
          fontSize: AppConstants.bodySize,
          color: ColorManager.white,
        ),
      ),
    ),
  );
}
