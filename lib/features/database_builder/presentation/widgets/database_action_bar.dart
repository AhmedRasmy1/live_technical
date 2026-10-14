import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../viewmodels/database_list_cubit/database_list_cubit.dart';
import 'sort_menu_button.dart';

/// Search + Filter + Sort + "Create Database".
/// On compact widths the search takes its own row and Filter / Sort shrink to
/// icons so the primary button keeps its label.
class DatabaseActionBar extends StatelessWidget {
  const DatabaseActionBar({
    super.key,
    required this.sort,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onSortSelected,
    required this.onCreatePressed,
  });

  final DatabaseSort sort;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final ValueChanged<DatabaseSort> onSortSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Larger system fonts make the buttons wider, so switch earlier.
        final compactWidth = MediaQuery.textScalerOf(
          context,
        ).scale(AppConstants.compactBreakpoint);
        final compact = constraints.maxWidth < compactWidth;

        final search = AppSearchField(onChanged: onSearchChanged);
        final filter = AppActionButton(
          label: 'Filter',
          icon: Icons.tune,
          height: AppConstants.buttonHeight,
          showLabel: !compact,
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.textSecondary,
          elevated: true,
          onPressed: onFilterPressed,
        );
        final sortButton = SortMenuButton(
          selected: sort,
          onSelected: onSortSelected,
          showLabel: !compact,
        );
        final create = AppActionButton(
          label: 'Create Database',
          icon: Icons.storage_outlined,
          height: AppConstants.buttonHeight,
          elevated: true,
          onPressed: onCreatePressed,
        );

        if (compact) {
          return Column(
            children: [
              search,
              const SizedBox(height: AppPadding.p12),
              Row(
                children: [
                  filter,
                  const SizedBox(width: AppPadding.p12),
                  sortButton,
                  const SizedBox(width: AppPadding.p12),
                  Expanded(child: create),
                ],
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: AppPadding.p16),
            filter,
            const SizedBox(width: AppPadding.p16),
            sortButton,
            const SizedBox(width: AppPadding.p16),
            create,
          ],
        );
      },
    );
  }
}
