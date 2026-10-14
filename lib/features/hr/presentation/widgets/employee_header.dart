import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';

/// Breadcrumb: "HR > Employee".
class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'HR',
          style: getRegularStyle(
            fontSize: AppConstants.titleSize,
            color: ColorManager.textGrey,
          ),
        ),
        const Icon(
          Icons.chevron_right,
          size: AppConstants.iconSize,
          color: ColorManager.black,
        ),
        Flexible(
          child: Text(
            'Employee',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getBoldStyle(
              fontSize: AppConstants.titleSize,
              color: ColorManager.black,
            ),
          ),
        ),
      ],
    );
  }
}
