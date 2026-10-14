import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_form_field.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import 'hr_options.dart';

/// Responsive form fields: 3 columns on wide, 2 on medium, 1 on compact screens.
class EmployeeFormFields extends StatelessWidget {
  const EmployeeFormFields({
    super.key,
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.jobTitleController,
    required this.onDepartmentChanged,
  });

  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final TextEditingController jobTitleController;
  final ValueChanged<String?> onDepartmentChanged;

  int _columnsFor(double width) {
    if (width >= AppConstants.wideBreakpoint) return 3;
    if (width >= AppConstants.compactBreakpoint) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final fieldWidth =
            (constraints.maxWidth - AppConstants.fieldSpacing * (columns - 1)) /
            columns;

        Widget sized(Widget child) => SizedBox(width: fieldWidth, child: child);

        return Wrap(
          spacing: AppConstants.fieldSpacing,
          runSpacing: AppConstants.fieldSpacing,
          children: [
            sized(
              AppTextFormField(
                label: 'First Name',
                controller: firstNameController,
                validator: Validators.requiredField,
              ),
            ),
            sized(
              AppTextFormField(
                label: 'Middle Name',
                controller: middleNameController,
              ),
            ),
            sized(
              AppTextFormField(
                label: 'Last Name',
                controller: lastNameController,
                validator: Validators.requiredField,
              ),
            ),
            sized(
              AppDropdownFormField(
                label: 'Department',
                items: HrOptions.departments,
                onChanged: onDepartmentChanged,
                validator: Validators.requiredField,
              ),
            ),
            sized(
              AppTextFormField(
                label: 'Job Title',
                controller: jobTitleController,
                validator: Validators.requiredField,
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        );
      },
    );
  }
}
