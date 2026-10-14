import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../domain/entities/employee_entity.dart';
import 'employee_card.dart';

/// Sliver grid that adapts to 1 / 2 / 3 columns depending on available width.
class EmployeeSliverGrid extends StatelessWidget {
  const EmployeeSliverGrid({super.key, required this.employees});

  final List<EmployeeEntity> employees;

  @override
  Widget build(BuildContext context) {
    // Keep the card tall enough when the user increases the system font size.
    final cardHeight = MediaQuery.textScalerOf(
      context,
    ).scale(AppConstants.employeeCardHeight);

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppConstants.cardMaxWidth,
        mainAxisExtent: cardHeight,
        mainAxisSpacing: AppConstants.fieldSpacing,
        crossAxisSpacing: AppConstants.fieldSpacing,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) => EmployeeCard(employee: employees[index]),
    );
  }
}
