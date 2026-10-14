import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_helper.dart';
import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/widgets/filter_dropdown.dart';
import '../../../../core/widgets/form_action_buttons.dart';
import '../../domain/entities/database_enums.dart';
import 'database_options.dart';

/// Filter dialog content: pick an access type, then Apply or Reset.
/// Only holds the dropdown selection (pure UI state).
class DatabaseFilterPanel extends StatefulWidget {
  const DatabaseFilterPanel({
    super.key,
    required this.onApply,
    required this.onReset,
    this.initialAccessType,
  });

  final AccessType? initialAccessType;

  /// `null` means "All".
  final ValueChanged<AccessType?> onApply;
  final VoidCallback onReset;

  @override
  State<DatabaseFilterPanel> createState() => _DatabaseFilterPanelState();
}

class _DatabaseFilterPanelState extends State<DatabaseFilterPanel> {
  AccessType? _accessType;

  @override
  void initState() {
    _accessType = widget.initialAccessType;
    super.initState();
  }

  AccessType? _fromLabel(String? label) {
    for (final type in AccessType.values) {
      if (type.label == label) return type;
    }
    return null; // "All"
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(
                  Icons.tune,
                  size: AppConstants.smallIconSize,
                  color: ColorManager.white,
                ),
              ),
              const SizedBox(width: AppPadding.p12),
              Text(
                'Filter',
                style: getRegularStyle(
                  fontSize: AppConstants.bodySize,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.fieldSpacing),
          FilterDropdown(
            hint: 'Access Type',
            items: [
              DatabaseOptions.allLabel,
              for (final type in AccessType.values) type.label,
            ],
            value: _accessType?.label,
            onChanged: (label) =>
                setState(() => _accessType = _fromLabel(label)),
          ),
          const SizedBox(height: AppConstants.fieldSpacing),
          FormActionButtons(
            discardLabel: 'Reset',
            submitLabel: 'Apply',
            onDiscard: () {
              setState(() => _accessType = null);
              widget.onReset();
            },
            onSubmit: () => widget.onApply(_accessType),
          ),
        ],
      ),
    );
  }
}
