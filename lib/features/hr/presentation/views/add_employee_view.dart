import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/breadcrumb_header.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../domain/entities/employee_entity.dart';
import '../viewmodels/add_employee_cubit/add_employee_cubit.dart';
import '../widgets/employee_form_actions.dart';
import '../widgets/employee_form_fields.dart';
import '../widgets/profile_image_picker.dart';

/// "HR > Employees > Adding New Employee".
/// Pops with `true` once the employee has been created.
class AddEmployeeView extends StatefulWidget {
  const AddEmployeeView({super.key});

  @override
  State<AddEmployeeView> createState() => _AddEmployeeViewState();
}

class _AddEmployeeViewState extends State<AddEmployeeView> {
  late AddEmployeeCubit addEmployeeCubit;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  String? _department;

  @override
  void initState() {
    addEmployeeCubit = getIt.get<AddEmployeeCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _jobTitleController.dispose();
    addEmployeeCubit.close();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Creating Employee',
        message: 'Are You Sure You Want To Create This Employee ?',
      ),
    );
    if (confirmed != true || !mounted) return;

    addEmployeeCubit.addEmployee(
      EmployeeEntity(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        department: _department ?? '',
        jobTitle: _jobTitleController.text.trim(),
      ),
    );
  }

  Future<void> _onSuccess() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessDialog(
        title: 'Successful',
        message: 'You Successfully Created Employee',
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _onFailure(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorManager.error,
        content: Text(
          error,
          style: getRegularStyle(
            fontSize: AppConstants.bodySize,
            color: ColorManager.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SafeArea(
        child: BlocConsumer<AddEmployeeCubit, AddEmployeeState>(
          bloc: addEmployeeCubit,
          listener: (context, state) {
            if (state is AddEmployeeSuccess) {
              _onSuccess();
            } else if (state is AddEmployeeFailure) {
              _onFailure(state.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is AddEmployeeLoading;
            return Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.contentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: CustomScrollView(
                          slivers: [
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppPadding.p16,
                                ),
                                child: BreadcrumbHeader(
                                  items: [
                                    'HR',
                                    'Employees',
                                    'Adding New Employee',
                                  ],
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppPadding.p16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: ProfileImagePicker(),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: EmployeeFormFields(
                                firstNameController: _firstNameController,
                                middleNameController: _middleNameController,
                                lastNameController: _lastNameController,
                                jobTitleController: _jobTitleController,
                                onDepartmentChanged: (value) =>
                                    _department = value,
                              ),
                            ),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppPadding.p24,
                                  ),
                                  child: EmployeeFormActions(
                                    onDiscard: () =>
                                        Navigator.of(context).pop(),
                                    onSubmit: _onSubmit,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: ColorManager.overlay,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
