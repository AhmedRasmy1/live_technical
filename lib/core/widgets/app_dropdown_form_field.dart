import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
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
    this.fillColor,
    this.value,
  });

  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final FormFieldValidator<String>? validator;
  final Color? fillColor;

  /// Currently selected item, so the field can be restored (e.g. when going
  /// back a step in a wizard).
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppPadding.p4),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          validator: validator,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          dropdownColor: context.colors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: AppConstants.iconSize,
            color: context.colors.textSecondary,
          ),
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: context.colors.textPrimary,
          ),
          decoration: appInputDecoration(context, fillColor: fillColor),
          hint: Text(
            hint,
            style: getRegularStyle(
              fontSize: AppConstants.captionSize,
              color: context.colors.textSecondary,
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
