import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_action_button.dart';

/// Centered message for the empty / error state of the employee list.
class EmployeeListMessage extends StatelessWidget {
  const EmployeeListMessage({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: AppConstants.bodySize,
                color: ColorManager.textGrey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.fieldSpacing),
              AppActionButton(
                label: 'Retry',
                icon: Icons.refresh,
                height: AppConstants.buttonHeight,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
