import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../domain/entities/database_entity.dart';
import 'database_card.dart';

/// Responsive grid: as many columns as fit [AppConstants.databaseCardMinWidth]
/// (1 on phones, 3 on tablets, more on desktop).
class DatabaseSliverGrid extends StatelessWidget {
  const DatabaseSliverGrid({super.key, required this.databases});

  final List<DatabaseEntity> databases;

  @override
  Widget build(BuildContext context) {
    // Keep the card tall enough when the user increases the system font size.
    final cardHeight = MediaQuery.textScalerOf(
      context,
    ).scale(AppConstants.databaseCardHeight);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppConstants.fieldSpacing;
        final columns = math.max(
          1,
          ((constraints.crossAxisExtent + spacing) /
                  (AppConstants.databaseCardMinWidth + spacing))
              .floor(),
        );
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: cardHeight,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemCount: databases.length,
          itemBuilder: (context, index) =>
              DatabaseCard(database: databases[index]),
        );
      },
    );
  }
}
