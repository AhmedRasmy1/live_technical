import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/bilingual_info_fields.dart';
import '../../../../core/widgets/breadcrumb_header.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/error_snack_bar.dart';
import '../../../../core/widgets/form_action_buttons.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/profile_image_picker.dart';
import '../../../../core/widgets/responsive_field_wrap.dart';
import '../../../../core/widgets/status_message.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../core/widgets/warning_dialog.dart';
import '../../../hr/presentation/widgets/employee_picker_filters.dart';
import '../../../hr/presentation/widgets/employee_selection_grid.dart';
import '../../../hr/presentation/widgets/selected_employee_avatars.dart';
import '../viewmodels/create_board_cubit/create_board_cubit.dart';
import '../widgets/board_options.dart';
import '../widgets/department_chips.dart';
import '../widgets/department_multi_select.dart';
import '../widgets/messaging_toggle_row.dart';

/// "Task Management > Creating New Board".
/// Pops with `true` once the board has been created.
class CreateBoardView extends StatefulWidget {
  const CreateBoardView({super.key});

  @override
  State<CreateBoardView> createState() => _CreateBoardViewState();
}

class _CreateBoardViewState extends State<CreateBoardView> {
  late CreateBoardCubit createBoardCubit;
  final _formKey = GlobalKey<FormState>();
  final _boardNameController = TextEditingController();
  final _boardNameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();

  @override
  void initState() {
    createBoardCubit = getIt.get<CreateBoardCubit>();
    super.initState();
    createBoardCubit.getEmployees();
  }

  @override
  void dispose() {
    _boardNameController.dispose();
    _boardNameArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    createBoardCubit.close();
    super.dispose();
  }

  String get _boardName => _boardNameController.text.trim();

  void _onCreate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    createBoardCubit.checkBoardName(_boardName);
  }

  Future<void> _onStateChanged(CreateBoardState state) async {
    switch (state) {
      case CreateBoardSuccess():
        switch (state.outcome) {
          case BoardOutcome.nameExists:
            await _showWarning();
          case BoardOutcome.nameAvailable:
            await _confirmAndCreate();
          case BoardOutcome.boardCreated:
            await _showSuccessAndClose();
          case BoardOutcome.employeesLoaded:
          case BoardOutcome.formChanged:
            break;
        }
      case CreateBoardFailure():
        if (state.operation != BoardOperation.loadEmployees) {
          showErrorSnackBar(context, state.error);
        }
      case CreateBoardInitial():
      case CreateBoardLoading():
        break;
    }
  }

  Future<void> _showWarning() {
    return showDialog<void>(
      context: context,
      builder: (_) => WarningDialog(
        message:
            '$_boardName Already Exist As A Board Please Choose A Different Name',
      ),
    );
  }

  Future<void> _confirmAndCreate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Creating Boards',
        message: 'Are You Sure You Want To Create This Board ?',
      ),
    );
    if (confirmed != true || !mounted) return;
    createBoardCubit.createBoard(
      boardName: _boardName,
      boardNameAr: _boardNameArController.text,
      description: _descriptionController.text,
      descriptionAr: _descriptionArController.text,
    );
  }

  Future<void> _showSuccessAndClose() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessDialog(
        title: 'Creating Boards',
        message: 'You Successfully Created This Board',
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _buildEmployees(CreateBoardState state) {
    final form = state.form;
    final isLoadingEmployees =
        state is CreateBoardInitial ||
        (state is CreateBoardLoading &&
            state.operation == BoardOperation.loadEmployees);
    if (isLoadingEmployees) {
      return const Padding(
        padding: EdgeInsets.all(AppPadding.p24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is CreateBoardFailure &&
        state.operation == BoardOperation.loadEmployees) {
      return StatusMessage(
        message: state.error,
        onRetry: createBoardCubit.getEmployees,
      );
    }

    final visible = form.visibleEmployees;
    if (visible.isEmpty) {
      return StatusMessage(
        message: 'No employees found',
        onRetry: form.employees.isEmpty ? createBoardCubit.getEmployees : null,
      );
    }
    return EmployeeSelectionGrid(
      employees: visible,
      selectedIds: form.selectedEmployeeIds,
      onToggle: createBoardCubit.toggleEmployee,
    );
  }

  Widget _buildPanel(CreateBoardState state) {
    final form = state.form;
    const gap = SizedBox(height: AppConstants.fieldSpacing);
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileImagePicker(),
          gap,
          BilingualInfoFields(
            titleLabel: 'Board Name',
            titleArLabel: 'اسم لوحة',
            titleController: _boardNameController,
            titleArController: _boardNameArController,
            descriptionController: _descriptionController,
            descriptionArController: _descriptionArController,
            titleValidator: createBoardCubit.validateBoardName,
          ),
          gap,
          ResponsiveFieldWrap(
            maxColumns: 2,
            children: [
              DepartmentMultiSelect(
                options: BoardOptions.departments,
                selected: form.selectedDepartments,
                onToggle: createBoardCubit.toggleDepartment,
                onToggleAll: () => createBoardCubit.toggleAllDepartments(
                  BoardOptions.departments,
                ),
              ),
            ],
          ),
          if (form.selectedDepartments.isNotEmpty) ...[
            const SizedBox(height: AppPadding.p12),
            DepartmentChips(
              departments: form.selectedDepartments,
              onRemove: createBoardCubit.removeDepartment,
            ),
          ],
          gap,
          MessagingToggleRow(
            value: form.isMessagingEnabled,
            onChanged: createBoardCubit.setMessagingEnabled,
          ),
          gap,
          Text(
            'Employee Information',
            style: getRegularStyle(fontSize: AppConstants.captionSize),
          ),
          const SizedBox(height: AppPadding.p8),
          EmployeePickerFilters(
            departments: form.employeeDepartments,
            selectedDepartment: form.employeeDepartment,
            onSearchChanged: createBoardCubit.searchEmployees,
            onDepartmentChanged: createBoardCubit.filterEmployeesByDepartment,
          ),
          if (form.selectedEmployeeIds.isNotEmpty) ...[
            gap,
            SelectedEmployeeAvatars(employees: form.selectedEmployees),
          ],
          gap,
          _buildEmployees(state),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: BlocConsumer<CreateBoardCubit, CreateBoardState>(
          bloc: createBoardCubit,
          listener: (context, state) => _onStateChanged(state),
          builder: (context, state) {
            final isBusy =
                state is CreateBoardLoading &&
                state.operation != BoardOperation.loadEmployees;
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
                                    'Task Management',
                                    'Creating New Board',
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(child: _buildPanel(state)),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppPadding.p24,
                                  ),
                                  child: FormActionButtons(
                                    submitLabel: 'Create',
                                    onDiscard: () =>
                                        Navigator.of(context).pop(),
                                    onSubmit: _onCreate,
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
                if (isBusy) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }
}
