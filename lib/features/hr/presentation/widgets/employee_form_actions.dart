import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/widgets/app_action_button.dart';

/// "Discard" (light grey) on the left and "Submit" (dark grey) on the right.
/// Buttons shrink instead of overflowing on narrow screens.
class EmployeeFormActions extends StatelessWidget {
  const EmployeeFormActions({
    super.key,
    required this.onDiscard,
    required this.onSubmit,
  });

  final VoidCallback onDiscard;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: AppPadding.p40);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: AppActionButton(
            label: 'Discard',
            height: AppConstants.buttonHeight,
            backgroundColor: ColorManager.lightGrey,
            padding: padding,
            onPressed: onDiscard,
          ),
        ),
        const SizedBox(width: AppPadding.p16),
        Flexible(
          child: AppActionButton(
            label: 'Submit',
            height: AppConstants.buttonHeight,
            padding: padding,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}
