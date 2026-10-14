import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/styles_manager.dart';
import 'app_action_button.dart';

/// Centered message for empty / error states, with an optional Retry button.
class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, required this.message, this.onRetry});

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
                color: context.colors.textSecondary,
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
