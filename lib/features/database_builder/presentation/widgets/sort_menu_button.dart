import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../viewmodels/database_list_cubit/database_list_cubit.dart';

/// "Sort" button that opens a small menu (Creation Date / Last Update).
/// The active option is highlighted.
class SortMenuButton extends StatelessWidget {
  const SortMenuButton({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showLabel = true,
  });

  final DatabaseSort selected;
  final ValueChanged<DatabaseSort> onSelected;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.borderRadius);
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(context.colors.surface),
        minimumSize: const WidgetStatePropertyAll(
          Size(AppConstants.menuMinWidth, 0),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      menuChildren: [
        for (final sort in DatabaseSort.values)
          MenuItemButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                sort == selected ? context.colors.lightGrey : null,
              ),
            ),
            onPressed: () => onSelected(sort),
            child: Text(
              sort.label,
              style: getRegularStyle(
                fontSize: AppConstants.captionSize,
                color: context.colors.textPrimary,
              ),
            ),
          ),
      ],
      builder: (context, controller, child) => AppActionButton(
        label: 'Sort',
        icon: Icons.sort,
        height: AppConstants.buttonHeight,
        showLabel: showLabel,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textSecondary,
        elevated: true,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
