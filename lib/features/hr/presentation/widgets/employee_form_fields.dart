import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_form_field.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/responsive_field_wrap.dart';
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveFieldWrap(
      children: [
        AppTextFormField(
          label: 'First Name',
          controller: firstNameController,
          validator: Validators.requiredField,
        ),
        AppTextFormField(
          label: 'Middle Name',
          controller: middleNameController,
        ),
        AppTextFormField(
          label: 'Last Name',
          controller: lastNameController,
          validator: Validators.requiredField,
        ),
        AppDropdownFormField(
          label: 'Department',
          items: HrOptions.departments,
          onChanged: onDepartmentChanged,
          validator: Validators.requiredField,
        ),
        AppTextFormField(
          label: 'Job Title',
          controller: jobTitleController,
          validator: Validators.requiredField,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
