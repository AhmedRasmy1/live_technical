import 'package:flutter/material.dart';

import '../../../../core/extensions/media_query_helper.dart';
import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_search_field.dart';

/// Search field + Filter button + Employee (active) button.
/// Buttons collapse to icon-only on compact screens.
class EmployeeActionBar extends StatelessWidget {
  const EmployeeActionBar({
    super.key,
    required this.onFilterPressed,
    this.onSearchChanged,
    this.onEmployeePressed,
  });

  final VoidCallback onFilterPressed;
  final VoidCallback? onEmployeePressed;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final showLabels = context.screenWidth >= AppConstants.compactBreakpoint;
    return Row(
      children: [
        Expanded(child: AppSearchField(onChanged: onSearchChanged)),
        const SizedBox(width: AppPadding.p16),
        AppActionButton(
          label: 'Filter',
          icon: Icons.tune,
          height: AppConstants.buttonHeight,
          showLabel: showLabels,
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.textSecondary,
          elevated: true,
          onPressed: onFilterPressed,
        ),
        const SizedBox(width: AppPadding.p16),
        AppActionButton(
          label: 'Employee',
          icon: Icons.badge_outlined,
          height: AppConstants.buttonHeight,
          showLabel: showLabels,
          onPressed: onEmployeePressed ?? () {},
        ),
      ],
    );
  }
}
