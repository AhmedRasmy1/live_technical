import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/filter_dropdown.dart';

/// Search field + department filter above the employee grid.
/// Shared by the board and database screens.
/// Stacks vertically on compact screens.
class EmployeePickerFilters extends StatelessWidget {
  const EmployeePickerFilters({
    super.key,
    required this.departments,
    required this.selectedDepartment,
    required this.onSearchChanged,
    required this.onDepartmentChanged,
    this.allLabel = 'All',
  });

  final List<String> departments;
  final String? selectedDepartment;
  final ValueChanged<String> onSearchChanged;

  /// Called with `null` when "All" is chosen.
  final ValueChanged<String?> onDepartmentChanged;

  /// The "no filter" entry at the top of the dropdown.
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final search = AppSearchField(
      onChanged: onSearchChanged,
      fillColor: context.colors.fieldFill,
    );
    final dropdown = FilterDropdown(
      hint: 'Department',
      items: [allLabel, ...departments],
      value: selectedDepartment,
      onChanged: (value) =>
          onDepartmentChanged(value == allLabel ? null : value),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppConstants.compactBreakpoint) {
          return Column(
            children: [
              search,
              const SizedBox(height: AppConstants.fieldSpacing),
              dropdown,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 3, child: search),
            const SizedBox(width: AppConstants.fieldSpacing),
            Expanded(child: dropdown),
          ],
        );
      },
    );
  }
}
