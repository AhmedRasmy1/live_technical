import 'package:flutter/material.dart';

import '../extensions/theme_helper.dart';
import '../resources/app_constants.dart';
import '../resources/styles_manager.dart';

/// Breadcrumb such as "HR > Employees > Adding New Employee".
/// The last item is bold, previous ones are regular grey. Wraps on small screens.
class BreadcrumbHeader extends StatelessWidget {
  const BreadcrumbHeader({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;
      children.add(
        Text(
          items[i],
          style: isLast
              ? getBoldStyle(
                  fontSize: AppConstants.titleSize,
                  color: context.colors.textPrimary,
                )
              : getRegularStyle(
                  fontSize: AppConstants.titleSize,
                  color: context.colors.textSecondary,
                ),
        ),
      );
      if (!isLast) {
        children.add(
          Icon(
            Icons.chevron_right,
            size: AppConstants.iconSize,
            color: context.colors.textPrimary,
          ),
        );
      }
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
