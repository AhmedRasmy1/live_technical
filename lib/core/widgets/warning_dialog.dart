import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

/// Red warning message. Closes when the user taps outside or goes back.
class WarningDialog extends StatelessWidget {
  const WarningDialog({
    super.key,
    required this.message,
    this.title = 'Warning',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.white,
      insetPadding: const EdgeInsets.all(AppPadding.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.dialogMaxWidth,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error,
                size: AppConstants.dialogIconSize,
                color: ColorManager.error,
              ),
              const SizedBox(height: AppPadding.p16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: getMediumStyle(fontSize: AppConstants.bodySize),
              ),
              const SizedBox(height: AppPadding.p8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: AppConstants.captionSize,
                  color: ColorManager.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
