import 'package:flutter/material.dart';

import '../resources/app_constants.dart';

/// Lays out form fields in equal columns: up to [maxColumns] on wide screens,
/// 2 on medium screens and 1 on compact screens.
class ResponsiveFieldWrap extends StatelessWidget {
  const ResponsiveFieldWrap({
    super.key,
    required this.children,
    this.maxColumns = 3,
  });

  final List<Widget> children;
  final int maxColumns;

  int _columnsFor(double width) {
    if (width >= AppConstants.wideBreakpoint) return maxColumns;
    if (width >= AppConstants.compactBreakpoint) {
      return maxColumns < 2 ? maxColumns : 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final fieldWidth =
            (constraints.maxWidth - AppConstants.fieldSpacing * (columns - 1)) /
            columns;
        return Wrap(
          spacing: AppConstants.fieldSpacing,
          runSpacing: AppConstants.fieldSpacing,
          children: [
            for (final child in children)
              SizedBox(width: fieldWidth, child: child),
          ],
        );
      },
    );
  }
}
