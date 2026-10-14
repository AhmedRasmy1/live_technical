import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';

/// One tab: a square counter (yellow when selected) followed by its label.
class DatabaseTabItem extends StatelessWidget {
  const DatabaseTabItem({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.borderRadius);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppConstants.tabCountSize,
                height: AppConstants.tabCountSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? ColorManager.accent
                      : context.colors.surface,
                  borderRadius: radius,
                ),
                child: Text(
                  '$count',
                  style: getMediumStyle(
                    fontSize: AppConstants.bodySize,
                    // The yellow stays bright in dark mode, so keep dark text.
                    color: selected
                        ? ColorManager.black
                        : context.colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppPadding.p12),
              Text(
                label,
                style: getRegularStyle(
                  fontSize: AppConstants.bodySize,
                  color: selected
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
