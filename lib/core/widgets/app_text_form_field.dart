import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'app_input_decoration.dart';

/// Label on top + validated text field.
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'Text Here',
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

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
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: ColorManager.black,
          ),
          decoration: appInputDecoration(hint: hint),
        ),
      ],
    );
  }
}
