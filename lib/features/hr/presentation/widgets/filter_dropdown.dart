import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';

/// Light-grey dropdown without underline.
class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.borderRadius);
    return Container(
      height: AppConstants.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.fieldFill,
        borderRadius: radius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          borderRadius: radius,
          dropdownColor: ColorManager.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: AppConstants.iconSize,
            color: ColorManager.black,
          ),
          hint: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getRegularStyle(
              fontSize: AppConstants.captionSize,
              color: ColorManager.textGrey,
            ),
          ),
          style: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: ColorManager.black,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<String>(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
