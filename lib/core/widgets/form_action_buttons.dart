import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import 'app_action_button.dart';

/// Discard (light grey, left) and a primary action (dark grey, right).
/// Buttons shrink instead of overflowing on narrow screens.
class FormActionButtons extends StatelessWidget {
  const FormActionButtons({
    super.key,
    required this.onDiscard,
    required this.onSubmit,
    this.discardLabel = 'Discard',
    this.submitLabel = 'Submit',
  });

  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final String discardLabel;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: AppPadding.p40);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: AppActionButton(
            label: discardLabel,
            height: AppConstants.buttonHeight,
            backgroundColor: context.colors.lightGrey,
            padding: padding,
            onPressed: onDiscard,
          ),
        ),
        const SizedBox(width: AppPadding.p16),
        Flexible(
          child: AppActionButton(
            label: submitLabel,
            height: AppConstants.buttonHeight,
            padding: padding,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}
