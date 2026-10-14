import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import 'board_options.dart';

/// Dropdown whose menu is a list of checkboxes ("All" first).
/// The menu stays open while the user ticks several departments.
class DepartmentMultiSelect extends StatelessWidget {
  const DepartmentMultiSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onToggleAll,
    this.label = 'Department',
    this.hint = 'Choose Department',
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onToggleAll;
  final String label;
  final String hint;

  Widget _item(String text, bool checked, VoidCallback onTap) {
    return MenuItemButton(
      closeOnActivate: false,
      onPressed: onTap,
      leadingIcon: Checkbox(
        value: checked,
        onChanged: (_) => onTap(),
        activeColor: ColorManager.accent,
        checkColor: ColorManager.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.checkboxRadius),
        ),
      ),
      child: Text(
        text,
        style: getRegularStyle(fontSize: AppConstants.captionSize),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = options.isNotEmpty && options.every(selected.contains);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: ColorManager.black,
          ),
        ),
        const SizedBox(height: AppPadding.p4),
        MenuAnchor(
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(ColorManager.white),
            minimumSize: const WidgetStatePropertyAll(
              Size(AppConstants.menuMinWidth, 0),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
          menuChildren: [
            _item(BoardOptions.allLabel, allSelected, onToggleAll),
            for (final option in options)
              _item(option, selected.contains(option), () => onToggle(option)),
          ],
          builder: (context, controller, child) => InkWell(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: Container(
              height: AppConstants.buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              decoration: BoxDecoration(
                color: ColorManager.fieldFill,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getRegularStyle(
                        fontSize: AppConstants.captionSize,
                        color: ColorManager.textGrey,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: AppConstants.iconSize,
                    color: ColorManager.textGrey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
