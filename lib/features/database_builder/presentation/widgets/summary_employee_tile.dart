import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../hr/domain/entities/employee_entity.dart';

/// One selected employee on the summary, with a red remove button.
class SummaryEmployeeTile extends StatelessWidget {
  const SummaryEmployeeTile({
    super.key,
    required this.employee,
    required this.onRemove,
  });

  final EmployeeEntity employee;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p12),
      decoration: BoxDecoration(
        color: context.colors.fieldFill,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          AppAvatar(imageUrl: employee.imageUrl),
          const SizedBox(width: AppPadding.p12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getMediumStyle(
                    fontSize: AppConstants.bodySize,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  employee.department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getRegularStyle(
                    fontSize: AppConstants.captionSize,
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  employee.jobTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getRegularStyle(
                    fontSize: AppConstants.captionSize,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppPadding.p8),
          IconButton.filled(
            tooltip: 'Remove ${employee.fullName}',
            onPressed: onRemove,
            style: IconButton.styleFrom(
              backgroundColor: ColorManager.error,
              foregroundColor: ColorManager.white,
              fixedSize: const Size.square(AppConstants.removeButtonSize),
            ),
            icon: const Icon(
              Icons.delete_outline,
              size: AppConstants.smallIconSize + AppPadding.p4,
            ),
          ),
        ],
      ),
    );
  }
}
