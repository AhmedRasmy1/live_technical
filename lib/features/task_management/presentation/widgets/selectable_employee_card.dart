import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../hr/domain/entities/employee_entity.dart';

/// Employee card with a checkbox on the right (yellow when selected).
class SelectableEmployeeCard extends StatelessWidget {
  const SelectableEmployeeCard({
    super.key,
    required this.employee,
    required this.selected,
    required this.onChanged,
  });

  final EmployeeEntity employee;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.borderRadius);
    return Material(
      color: ColorManager.fieldFill,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onChanged,
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p12),
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
                      style: getMediumStyle(fontSize: AppConstants.bodySize),
                    ),
                    Text(
                      employee.department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getRegularStyle(
                        fontSize: AppConstants.captionSize,
                        color: ColorManager.textGrey,
                      ),
                    ),
                    Text(
                      employee.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getRegularStyle(
                        fontSize: AppConstants.captionSize,
                        color: ColorManager.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: selected,
                onChanged: (_) => onChanged(),
                activeColor: ColorManager.accent,
                checkColor: ColorManager.white,
                side: const BorderSide(color: ColorManager.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.checkboxRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
