import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/filter_dropdown.dart';

/// Reusable filter panel: title, two dropdowns, Reset / Apply.
/// Only holds the local selection of the dropdowns (pure UI state).
class FilterPanelWidget extends StatefulWidget {
  const FilterPanelWidget({
    super.key,
    required this.jobTitles,
    required this.departments,
    required this.onApply,
    required this.onReset,
    this.initialJobTitle,
    this.initialDepartment,
  });

  final List<String> jobTitles;
  final List<String> departments;
  final String? initialJobTitle;
  final String? initialDepartment;
  final void Function(String? jobTitle, String? department) onApply;
  final VoidCallback onReset;

  @override
  State<FilterPanelWidget> createState() => _FilterPanelWidgetState();
}

class _FilterPanelWidgetState extends State<FilterPanelWidget> {
  String? _jobTitle;
  String? _department;

  @override
  void initState() {
    _jobTitle = widget.initialJobTitle;
    _department = widget.initialDepartment;
    super.initState();
  }

  void _reset() {
    setState(() {
      _jobTitle = null;
      _department = null;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final jobTitleDropdown = FilterDropdown(
      hint: 'Job Title',
      items: widget.jobTitles,
      value: _jobTitle,
      onChanged: (value) => setState(() => _jobTitle = value),
    );
    final departmentDropdown = FilterDropdown(
      hint: 'Department',
      items: widget.departments,
      value: _department,
      onChanged: (value) => setState(() => _department = value),
    );

    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppConstants.iconSize / 2 + AppPadding.p4,
                backgroundColor: context.colors.textSecondary,
                child: Icon(
                  Icons.tune,
                  size: AppConstants.smallIconSize,
                  color: ColorManager.white,
                ),
              ),
              const SizedBox(width: AppPadding.p12),
              Text(
                'Filter',
                style: getRegularStyle(fontSize: AppConstants.bodySize),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.fieldSpacing),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < AppConstants.filterStackBreakpoint) {
                return Column(
                  children: [
                    jobTitleDropdown,
                    const SizedBox(height: AppConstants.fieldSpacing),
                    departmentDropdown,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: jobTitleDropdown),
                  const SizedBox(width: AppConstants.fieldSpacing),
                  Expanded(child: departmentDropdown),
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.fieldSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AppActionButton(
                  label: 'Reset',
                  height: AppConstants.buttonHeight,
                  backgroundColor: context.colors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p24,
                  ),
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: AppPadding.p16),
              Flexible(
                child: AppActionButton(
                  label: 'Apply',
                  height: AppConstants.buttonHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p24,
                  ),
                  onPressed: () => widget.onApply(_jobTitle, _department),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
