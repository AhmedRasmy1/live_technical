import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/widgets/app_dropdown_form_field.dart';
import '../../../../core/widgets/bilingual_info_fields.dart';
import '../../../../core/widgets/profile_image_picker.dart';
import '../viewmodels/create_database_cubit/create_database_cubit.dart';
import 'database_options.dart';
import 'database_wizard_panel.dart';

/// Wizard step 1: icon, title, description (with live counter) and access.
/// Fields are pre-filled from the cubit form, so coming back from step 2
/// shows what was typed. The owning view validates through [formKey].
class DatabaseDetailsStep extends StatefulWidget {
  const DatabaseDetailsStep({
    super.key,
    required this.cubit,
    required this.formKey,
  });

  final CreateDatabaseCubit cubit;
  final GlobalKey<FormState> formKey;

  @override
  State<DatabaseDetailsStep> createState() => _DatabaseDetailsStepState();
}

class _DatabaseDetailsStepState extends State<DatabaseDetailsStep> {
  late final TextEditingController _title;
  late final TextEditingController _titleAr;
  late final TextEditingController _description;
  late final TextEditingController _descriptionAr;

  CreateDatabaseCubit get _cubit => widget.cubit;

  @override
  void initState() {
    super.initState();
    final form = _cubit.form;
    _title = TextEditingController(text: form.title);
    _titleAr = TextEditingController(text: form.titleAr);
    _description = TextEditingController(text: form.description);
    _descriptionAr = TextEditingController(text: form.descriptionAr);
  }

  @override
  void dispose() {
    _title.dispose();
    _titleAr.dispose();
    _description.dispose();
    _descriptionAr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppConstants.fieldSpacing);
    return DatabaseWizardPanel(
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileImagePicker(semanticLabel: 'Choose database image'),
            gap,
            BilingualInfoFields(
              titleLabel: 'Database Title',
              titleArLabel: 'عنوان قاعدة البيانات',
              titleController: _title,
              titleArController: _titleAr,
              descriptionController: _description,
              descriptionArController: _descriptionAr,
              titleValidator: _cubit.validateTitle,
              descriptionValidator: _cubit.validateDescription,
              onTitleChanged: _cubit.setTitle,
              onTitleArChanged: _cubit.setTitleAr,
              onDescriptionChanged: _cubit.setDescription,
              onDescriptionArChanged: _cubit.setDescriptionAr,
            ),
            gap,
            AppDropdownFormField(
              label: 'Access Management',
              items: DatabaseOptions.accessLabels,
              value: _cubit.form.accessType?.label,
              fillColor: context.colors.fieldFill,
              validator: (label) => _cubit.validateAccessType(
                DatabaseOptions.accessTypeFromLabel(label),
              ),
              onChanged: (label) {
                final type = DatabaseOptions.accessTypeFromLabel(label);
                if (type != null) _cubit.setAccessType(type);
              },
            ),
          ],
        ),
      ),
    );
  }
}
