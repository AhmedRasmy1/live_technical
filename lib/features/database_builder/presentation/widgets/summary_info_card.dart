import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/styles_manager.dart';

/// Read-only label + value card ("Total Employees", "Access Management").
class SummaryInfoCard extends StatelessWidget {
  const SummaryInfoCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: context.colors.fieldFill,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getRegularStyle(
              fontSize: AppConstants.captionSize,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppPadding.p4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getMediumStyle(
              fontSize: AppConstants.bodySize,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
