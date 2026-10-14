import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_date_form_field.dart';
import '../../../../core/widgets/app_dropdown_form_field.dart';
import '../../../../core/widgets/responsive_field_wrap.dart';
import '../../../../core/widgets/status_message.dart';
import '../viewmodels/create_database_cubit/create_database_cubit.dart';
import 'database_options.dart';
import 'database_wizard_panel.dart';
import 'summary_employee_tile.dart';
import 'summary_info_card.dart';

/// Wizard step 3 (summary): read-only totals, permissions, start / end dates
/// and the selected employees, each with a remove button.
/// The owning view validates through [formKey] before granting access.
class DatabaseSummaryStep extends StatefulWidget {
  const DatabaseSummaryStep({
    super.key,
    required this.cubit,
    required this.form,
    required this.formKey,
  });

  final CreateDatabaseCubit cubit;
  final CreateDatabaseForm form;
  final GlobalKey<FormState> formKey;

  @override
  State<DatabaseSummaryStep> createState() => _DatabaseSummaryStepState();
}

class _DatabaseSummaryStepState extends State<DatabaseSummaryStep> {
  final _endDateKey = GlobalKey<FormFieldState<DateTime>>();

  CreateDatabaseCubit get _cubit => widget.cubit;

  void _onStartChanged(DateTime value) {
    _cubit.setStartDate(value);
    // The end date may now be invalid (or valid again).
    if (_cubit.form.endDate != null) _endDateKey.currentState?.validate();
  }

  Widget _buildEmployees() {
    final employees = widget.form.selectedEmployees;
    if (employees.isEmpty) {
      return const StatusMessage(message: 'No employees selected');
    }
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
        return SummaryEmployeeTile(
          key: ValueKey(employee.id),
          employee: employee,
          onRemove: () => _cubit.removeEmployee(employee.id ?? ''),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final fill = context.colors.fieldFill;
    const gap = SizedBox(height: AppConstants.fieldSpacing);
    return DatabaseWizardPanel(
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveFieldWrap(
              maxColumns: 2,
              children: [
                SummaryInfoCard(
                  label: 'Total Employees',
                  value: '${form.totalEmployees}',
                ),
                SummaryInfoCard(
                  label: 'Access Management',
                  value: form.accessType?.label ?? '-',
                ),
              ],
            ),
            gap,
            ResponsiveFieldWrap(
              children: [
                AppDropdownFormField(
                  label: 'Permissions',
                  items: DatabaseOptions.permissionLabels,
                  value: form.permissions?.label,
                  fillColor: fill,
                  validator: (label) => _cubit.validatePermissions(
                    DatabaseOptions.permissionFromLabel(label),
                  ),
                  onChanged: (label) {
                    final permission = DatabaseOptions.permissionFromLabel(
                      label,
                    );
                    if (permission != null) _cubit.setPermissions(permission);
                  },
                ),
                AppDateFormField(
                  label: 'Start Date',
                  initialValue: form.startDate,
                  fillColor: fill,
                  validator: _cubit.validateStartDate,
                  onChanged: _onStartChanged,
                ),
                AppDateFormField(
                  key: _endDateKey,
                  label: 'End Date',
                  initialValue: form.endDate,
                  fillColor: fill,
                  validator: _cubit.validateEndDate,
                  onChanged: _cubit.setEndDate,
                ),
              ],
            ),
            gap,
            Text(
              'Selected Employees',
              style: getRegularStyle(fontSize: AppConstants.captionSize),
            ),
            const SizedBox(height: AppPadding.p8),
            _buildEmployees(),
          ],
        ),
      ),
    );
  }
}
