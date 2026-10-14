import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../widgets/employee_action_bar.dart';
import '../widgets/employee_grid.dart';
import '../widgets/employee_header.dart';
import '../widgets/employee_mock.dart';
import '../widgets/filter_panel_widget.dart';

class EmployeeView extends StatelessWidget {
  const EmployeeView({super.key});

  void _openFilter(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: ColorManager.white,
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
              jobTitles: mockJobTitles,
              departments: mockDepartments,
              onApply: (jobTitle, department) =>
                  Navigator.of(dialogContext).pop(),
              onReset: () => Navigator.of(dialogContext).pop(),
            ),
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
                      child: EmployeeHeader(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p16),
                      child: EmployeeActionBar(
                        onFilterPressed: () => _openFilter(context),
                      ),
                    ),
                  ),
                  const EmployeeSliverGrid(employees: mockEmployees),
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
