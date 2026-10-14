import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/database_entity.dart';

/// Dashboard card: icon tile, title and the key facts of one database.
class DatabaseCard extends StatelessWidget {
  const DatabaseCard({super.key, required this.database, this.onMenuPressed});

  final DatabaseEntity database;

  /// The "..." button. Shown but inactive while there is no menu yet.
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.borderRadius);
    final tables = database.tablesCount == 0 ? '-' : '${database.tablesCount}';

    return Container(
      padding: const EdgeInsets.all(AppPadding.p12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: radius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppConstants.databaseTileSize,
            height: AppConstants.databaseTileSize,
            decoration: BoxDecoration(
              color: context.colors.fieldFill,
              borderRadius: radius,
            ),
            child: Icon(
              Icons.storage_outlined,
              size: AppConstants.iconSize,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: AppPadding.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        database.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getMediumStyle(
                          fontSize: AppConstants.bodySize,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: radius,
                      onTap: onMenuPressed,
                      child: Icon(
                        Icons.more_horiz,
                        size: AppConstants.iconSize,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.p4),
                _InfoLine(label: 'No. Of Tables', value: tables),
                _InfoLine(
                  label: 'Creation',
                  value: formatDate(database.creationDate),
                ),
                if (database.isDeleted)
                  _InfoLine(
                    label: 'Deleted',
                    value: formatDate(database.deletedDate),
                  )
                else
                  _InfoLine(
                    label: 'Last Edit',
                    value: formatDate(database.lastEditDate),
                  ),
                _InfoLine(label: 'Access', value: database.accessType.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Label: value" in one line, label grey and value dark.
class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: getRegularStyle(
              fontSize: AppConstants.captionSize,
              color: context.colors.textSecondary,
            ),
          ),
          TextSpan(
            text: value,
            style: getRegularStyle(
              fontSize: AppConstants.captionSize,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
