import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import 'app_text_form_field.dart';
import 'responsive_field_wrap.dart';

/// Title and description, English with their Arabic (right-to-left) twins.
/// Shared by the board and database forms; every callback is optional.
class BilingualInfoFields extends StatelessWidget {
  const BilingualInfoFields({
    super.key,
    required this.titleLabel,
    required this.titleArLabel,
    required this.titleController,
    required this.titleArController,
    required this.descriptionController,
    required this.descriptionArController,
    this.titleValidator,
    this.descriptionValidator,
    this.onTitleChanged,
    this.onTitleArChanged,
    this.onDescriptionChanged,
    this.onDescriptionArChanged,
  });

  final String titleLabel;
  final String titleArLabel;
  final TextEditingController titleController;
  final TextEditingController titleArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final FormFieldValidator<String>? titleValidator;
  final FormFieldValidator<String>? descriptionValidator;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onTitleArChanged;
  final ValueChanged<String>? onDescriptionChanged;
  final ValueChanged<String>? onDescriptionArChanged;

  static const String descriptionLabel = 'Description';
  static const String descriptionArLabel = 'وصف';
  static const String arabicHint = 'اكتب هنا';

  @override
  Widget build(BuildContext context) {
    final fill = context.colors.fieldFill;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveFieldWrap(
          maxColumns: 2,
          children: [
            AppTextFormField(
              label: titleLabel,
              controller: titleController,
              validator: titleValidator,
              onChanged: onTitleChanged,
              fillColor: fill,
            ),
            AppTextFormField(
              label: titleArLabel,
              hint: arabicHint,
              controller: titleArController,
              onChanged: onTitleArChanged,
              textDirection: TextDirection.rtl,
              fillColor: fill,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.fieldSpacing),
        AppTextFormField(
          label: descriptionLabel,
          hint: 'Text here',
          controller: descriptionController,
          validator: descriptionValidator,
          onChanged: onDescriptionChanged,
          minLines: AppConstants.descriptionMinLines,
          maxLines: AppConstants.descriptionMaxLines,
          maxLength: AppConstants.descriptionMaxLength,
          fillColor: fill,
        ),
        const SizedBox(height: AppConstants.fieldSpacing),
        AppTextFormField(
          label: descriptionArLabel,
          hint: arabicHint,
          controller: descriptionArController,
          onChanged: onDescriptionArChanged,
          minLines: AppConstants.descriptionMinLines,
          maxLines: AppConstants.descriptionMaxLines,
          maxLength: AppConstants.descriptionMaxLength,
          textDirection: TextDirection.rtl,
          fillColor: fill,
        ),
      ],
    );
  }
}
