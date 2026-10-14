import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'app_input_decoration.dart';

/// Label on top + validated dropdown that matches [AppTextFormField].
class AppDropdownFormField extends StatelessWidget {
  const AppDropdownFormField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.hint = 'Select',
    this.validator,
  });

  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: ColorManager.black,
          ),
        ),
        const SizedBox(height: AppPadding.p4),
        DropdownButtonFormField<String>(
          isExpanded: true,
          validator: validator,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          dropdownColor: ColorManager.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: AppConstants.iconSize,
            color: ColorManager.textGrey,
          ),
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: ColorManager.black,
          ),
          decoration: appInputDecoration(hint: hint),
          hint: Text(
            hint,
            style: getRegularStyle(
              fontSize: AppConstants.captionSize,
              color: ColorManager.textGrey,
            ),
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<String>(value: item, child: Text(item)),
          ],
        ),
      ],
    );
  }
}
