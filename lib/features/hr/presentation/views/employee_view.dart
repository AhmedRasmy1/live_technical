import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/widgets/breadcrumb_header.dart';
import '../../../../core/widgets/status_message.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../viewmodels/employee_list_cubit/employee_list_cubit.dart';
import '../widgets/employee_action_bar.dart';
import '../widgets/employee_grid.dart';
import '../widgets/filter_panel_widget.dart';
import '../widgets/hr_options.dart';
import 'add_employee_view.dart';

class EmployeeView extends StatefulWidget {
  const EmployeeView({super.key});

  @override
  State<EmployeeView> createState() => _EmployeeViewState();
}

class _EmployeeViewState extends State<EmployeeView> {
  late EmployeeListCubit employeeListCubit;

  @override
  void initState() {
    employeeListCubit = getIt.get<EmployeeListCubit>();
    super.initState();
    employeeListCubit.getEmployees();
  }

  @override
  void dispose() {
    employeeListCubit.close();
    super.dispose();
  }

  Future<void> _openAddEmployee() async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddEmployeeView()));
    if (added == true) {
      employeeListCubit.getEmployees();
    }
  }

  void _openFilter() {
    final jobTitles = employeeListCubit.jobTitles;
    final selectedJobTitle = employeeListCubit.selectedJobTitle;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: context.colors.surface,
        insetPadding: const EdgeInsets.all(AppPadding.p16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.filterPanelMaxWidth,
          ),
          child: SingleChildScrollView(
            child: FilterPanelWidget(
              jobTitles: jobTitles,
              departments: HrOptions.departments,
              initialJobTitle: jobTitles.contains(selectedJobTitle)
                  ? selectedJobTitle
                  : null,
              initialDepartment: employeeListCubit.selectedDepartment,
              onApply: (jobTitle, department) {
                employeeListCubit.applyFilter(
                  department: department,
                  jobTitle: jobTitle,
                );
                Navigator.of(dialogContext).pop();
              },
              onReset: () {
                employeeListCubit.resetFilter();
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployees(EmployeeListState state) {
    switch (state) {
      case EmployeeListInitial():
      case EmployeeListLoading():
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        );
      case EmployeeListFailure():
        return SliverFillRemaining(
          hasScrollBody: false,
          child: StatusMessage(
            message: state.error,
            onRetry: employeeListCubit.getEmployees,
          ),
        );
      case EmployeeListSuccess():
        if (state.employees.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: StatusMessage(message: 'No employees found'),
          );
        }
        return EmployeeSliverGrid(employees: state.employees);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
                      child: Row(
                        children: [
                          Expanded(
                            child: BreadcrumbHeader(items: ['HR', 'Employee']),
                          ),
                          ThemeToggleButton(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p16),
                      child: EmployeeActionBar(
                        onFilterPressed: _openFilter,
                        onSearchChanged: employeeListCubit.searchEmployees,
                        onEmployeePressed: _openAddEmployee,
                      ),
                    ),
                  ),
                  BlocBuilder<EmployeeListCubit, EmployeeListState>(
                    bloc: employeeListCubit,
                    builder: (context, state) => _buildEmployees(state),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppPadding.p24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
