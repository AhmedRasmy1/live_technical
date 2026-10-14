import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../hr/presentation/views/employee_view.dart';
import '../../../task_management/presentation/views/create_board_view.dart';

/// Temporary launcher until the real navigation exists.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.dialogMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppActionButton(
                    label: 'HR > Employee',
                    icon: Icons.badge_outlined,
                    height: AppConstants.buttonHeight,
                    onPressed: () => _open(context, const EmployeeView()),
                  ),
                  const SizedBox(height: AppConstants.fieldSpacing),
                  AppActionButton(
                    label: 'Task Management > Create Board',
                    icon: Icons.dashboard_customize_outlined,
                    height: AppConstants.buttonHeight,
                    onPressed: () => _open(context, const CreateBoardView()),
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
