import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/status_message.dart';
import '../../../hr/presentation/widgets/employee_picker_filters.dart';
import '../../../hr/presentation/widgets/employee_selection_grid.dart';
import '../../../hr/presentation/widgets/selected_employee_avatars.dart';
import '../viewmodels/create_database_cubit/create_database_cubit.dart';
import 'database_wizard_panel.dart';

/// Wizard step 2: search + department filter, the avatars picked so far and
/// the selectable grid of real employees.
class DatabaseMembersStep extends StatelessWidget {
  const DatabaseMembersStep({
    super.key,
    required this.cubit,
    required this.state,
  });

  final CreateDatabaseCubit cubit;
  final CreateDatabaseState state;

  bool get _isLoading =>
      state is CreateDatabaseInitial ||
      (state is CreateDatabaseLoading &&
          (state as CreateDatabaseLoading).operation ==
              CreateDatabaseOperation.loadEmployees);

  Widget _buildEmployees() {
    final form = state.form;
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppPadding.p24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final current = state;
    if (current is CreateDatabaseFailure &&
        current.operation == CreateDatabaseOperation.loadEmployees) {
      return StatusMessage(message: current.error, onRetry: cubit.getEmployees);
    }

    final visible = form.visibleEmployees;
    if (visible.isEmpty) {
      return StatusMessage(
        message: 'No employees found',
        onRetry: form.employees.isEmpty ? cubit.getEmployees : null,
      );
    }
    return EmployeeSelectionGrid(
      employees: visible,
      selectedIds: form.selectedEmployeeIds,
      onToggle: cubit.toggleEmployee,
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = state.form;
    const gap = SizedBox(height: AppConstants.fieldSpacing);
    return DatabaseWizardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Members',
            style: getRegularStyle(fontSize: AppConstants.captionSize),
          ),
          const SizedBox(height: AppPadding.p8),
          EmployeePickerFilters(
            departments: form.employeeDepartments,
            selectedDepartment: form.employeeDepartment,
            onSearchChanged: cubit.searchEmployees,
            onDepartmentChanged: cubit.filterEmployeesByDepartment,
          ),
          if (form.hasMembers) ...[
            gap,
            SelectedEmployeeAvatars(
              employees: form.selectedEmployees,
              onRemove: cubit.removeEmployee,
            ),
          ],
          gap,
          _buildEmployees(),
        ],
      ),
    );
  }
}
