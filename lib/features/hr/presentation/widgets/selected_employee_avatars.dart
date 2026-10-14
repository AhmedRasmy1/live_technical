import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../domain/entities/employee_entity.dart';

/// Horizontal row of avatars for the employees picked so far.
/// When [onRemove] is given every avatar gets a small red badge that removes
/// that employee.
class SelectedEmployeeAvatars extends StatelessWidget {
  const SelectedEmployeeAvatars({
    super.key,
    required this.employees,
    this.onRemove,
  });

  final List<EmployeeEntity> employees;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: AppConstants.avatarRadius * 2 + AppPadding.p8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: AppPadding.p8),
        itemCount: employees.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppPadding.p8),
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Tooltip(
            message: employee.fullName,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(imageUrl: employee.imageUrl),
                if (onRemove != null)
                  PositionedDirectional(
                    top: -AppPadding.p4,
                    end: -AppPadding.p4,
                    child: Semantics(
                      button: true,
                      label: 'Remove ${employee.fullName}',
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onRemove!(employee.id ?? ''),
                        child: const CircleAvatar(
                          radius: AppConstants.avatarBadgeRadius / 2 + 1,
                          backgroundColor: ColorManager.error,
                          child: Icon(
                            Icons.close,
                            size: AppConstants.avatarBadgeRadius,
                            color: ColorManager.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
