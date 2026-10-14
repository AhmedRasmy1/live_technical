import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/styles_manager.dart';
import 'app_input_decoration.dart';

/// Label on top + validated text field.
/// Supports multiline ([minLines] / [maxLines]), a character counter
/// ([maxLength]) and right-to-left fields ([textDirection]).
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'Text Here',
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.textDirection,
    this.fillColor,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextDirection? textDirection;
  final Color? fillColor;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines == null || maxLines! > 1;
    final content = Column(
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
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType:
              keyboardType ?? (isMultiline ? TextInputType.multiline : null),
          textInputAction: isMultiline
              ? TextInputAction.newline
              : textInputAction,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: context.colors.textPrimary,
          ),
          decoration: appInputDecoration(
            context,
            hint: hint,
            fillColor: fillColor,
          ),
        ),
      ],
    );

    if (textDirection == null) return content;
    return Directionality(textDirection: textDirection!, child: content);
  }
}
