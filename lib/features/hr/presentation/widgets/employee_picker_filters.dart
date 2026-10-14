import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/filter_dropdown.dart';
import 'board_options.dart';

/// Search field + department filter above the employee grid.
/// Stacks vertically on compact screens.
class EmployeePickerFilters extends StatelessWidget {
  const EmployeePickerFilters({
    super.key,
    required this.departments,
    required this.selectedDepartment,
    required this.onSearchChanged,
    required this.onDepartmentChanged,
  });

  final List<String> departments;
  final String? selectedDepartment;
  final ValueChanged<String> onSearchChanged;

  /// Called with `null` when "All" is chosen.
  final ValueChanged<String?> onDepartmentChanged;

  @override
  Widget build(BuildContext context) {
    final search = AppSearchField(
      onChanged: onSearchChanged,
      fillColor: context.colors.fieldFill,
    );
    final dropdown = FilterDropdown(
      hint: 'Department',
      items: [BoardOptions.allLabel, ...departments],
      value: selectedDepartment,
      onChanged: (value) =>
          onDepartmentChanged(value == BoardOptions.allLabel ? null : value),
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
