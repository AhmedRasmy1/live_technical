import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/color_manager.dart';
import '../../domain/entities/employee_entity.dart';
import 'selectable_employee_card.dart';

/// Responsive 1 / 2 / 3 column grid of selectable employees.
/// It sizes itself to its content, so it can live inside a scroll view.
class EmployeeSelectionGrid extends StatelessWidget {
  const EmployeeSelectionGrid({
    super.key,
    required this.employees,
    required this.selectedIds,
    required this.onToggle,
    this.activeColor = ColorManager.accent,
  });

  final List<EmployeeEntity> employees;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.textScalerOf(
      context,
    ).scale(AppConstants.employeeCardHeight);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppConstants.cardMaxWidth,
        mainAxisExtent: cardHeight,
        mainAxisSpacing: AppConstants.fieldSpacing,
        crossAxisSpacing: AppConstants.fieldSpacing,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final id = employee.id ?? '';
        return SelectableEmployeeCard(
          employee: employee,
          selected: selectedIds.contains(id),
          onChanged: () => onToggle(id),
          activeColor: activeColor,
        );
      },
    );
  }
}
