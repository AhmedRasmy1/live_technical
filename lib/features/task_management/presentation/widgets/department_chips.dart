import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';

/// Selected departments as grey chips with a red minus to remove them.
class DepartmentChips extends StatelessWidget {
  const DepartmentChips({
    super.key,
    required this.departments,
    required this.onRemove,
  });

  final List<String> departments;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (departments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppPadding.p8,
      runSpacing: AppPadding.p8,
      children: [
        for (final department in departments)
          Chip(
            backgroundColor: ColorManager.fieldFill,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            label: Text(
              department,
              style: getRegularStyle(fontSize: AppConstants.captionSize),
            ),
            deleteIcon: const Icon(
              Icons.remove_circle,
              size: AppConstants.smallIconSize,
              color: ColorManager.error,
            ),
            deleteButtonTooltipMessage: 'Remove $department',
            onDeleted: () => onRemove(department),
          ),
      ],
    );
  }
}
