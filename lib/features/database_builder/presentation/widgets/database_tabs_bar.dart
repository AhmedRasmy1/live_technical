import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../viewmodels/database_list_cubit/database_list_cubit.dart';
import 'database_tab_item.dart';

/// All / Open / Restricted / Personal / Drafts / Deleted with live counters.
/// Scrolls horizontally when the tabs do not fit the screen.
class DatabaseTabsBar extends StatelessWidget {
  const DatabaseTabsBar({
    super.key,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  final Map<DatabaseTab, int> counts;
  final DatabaseTab selected;
  final ValueChanged<DatabaseTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in DatabaseTab.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                end: AppConstants.tabSpacing,
              ),
              child: DatabaseTabItem(
                key: ValueKey('tab-${tab.name}'),
                label: tab.label,
                count: counts[tab] ?? 0,
                selected: tab == selected,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}
