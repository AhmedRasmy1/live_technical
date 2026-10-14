import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'app_action_button.dart';

/// Yes / No dialog. Pops `true` for confirm and `false` for cancel.
///
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (_) => const ConfirmationDialog(title: '...', message: '...'),
/// );
/// ```
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.note_add_outlined,
    this.iconColor = ColorManager.warning,
    this.confirmLabel = 'Yes',
    this.cancelLabel = 'No',
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
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
              Icon(icon, size: AppConstants.dialogIconSize, color: iconColor),
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
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppPadding.p24),
              Row(
                children: [
                  Expanded(
                    child: AppActionButton(
                      label: cancelLabel,
                      height: AppConstants.buttonHeight,
                      backgroundColor: context.colors.lightGrey,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppPadding.p16),
                  Expanded(
                    child: AppActionButton(
                      label: confirmLabel,
                      height: AppConstants.buttonHeight,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
