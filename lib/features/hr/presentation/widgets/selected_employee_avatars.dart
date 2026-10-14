import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../hr/domain/entities/employee_entity.dart';

/// Horizontal row of avatars for the employees picked so far.
class SelectedEmployeeAvatars extends StatelessWidget {
  const SelectedEmployeeAvatars({super.key, required this.employees});

  final List<EmployeeEntity> employees;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: AppConstants.avatarRadius * 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: employees.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppPadding.p8),
        itemBuilder: (context, index) => Tooltip(
          message: employees[index].fullName,
          child: AppAvatar(imageUrl: employees[index].imageUrl),
        ),
      ),
    );
  }
}
