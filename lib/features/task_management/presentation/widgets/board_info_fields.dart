import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/responsive_field_wrap.dart';

/// Board name and description, English with its Arabic (right-to-left) twin.
class BoardInfoFields extends StatelessWidget {
  const BoardInfoFields({
    super.key,
    required this.boardNameController,
    required this.boardNameArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.boardNameValidator,
  });

  final TextEditingController boardNameController;
  final TextEditingController boardNameArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final FormFieldValidator<String> boardNameValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveFieldWrap(
          maxColumns: 2,
          children: [
            AppTextFormField(
              label: 'Board Name',
              controller: boardNameController,
              validator: boardNameValidator,
              fillColor: ColorManager.fieldFill,
            ),
            AppTextFormField(
              label: 'اسم لوحة',
              hint: 'اكتب هنا',
              controller: boardNameArController,
              textDirection: TextDirection.rtl,
              fillColor: ColorManager.fieldFill,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.fieldSpacing),
        AppTextFormField(
          label: 'Description',
          hint: 'Text here',
          controller: descriptionController,
          minLines: AppConstants.descriptionMinLines,
          maxLines: AppConstants.descriptionMaxLines,
          maxLength: AppConstants.descriptionMaxLength,
          fillColor: ColorManager.fieldFill,
        ),
        const SizedBox(height: AppConstants.fieldSpacing),
        AppTextFormField(
          label: 'وصف',
          hint: 'اكتب هنا',
          controller: descriptionArController,
          minLines: AppConstants.descriptionMinLines,
          maxLines: AppConstants.descriptionMaxLines,
          maxLength: AppConstants.descriptionMaxLength,
          textDirection: TextDirection.rtl,
          fillColor: ColorManager.fieldFill,
        ),
      ],
    );
  }
}
