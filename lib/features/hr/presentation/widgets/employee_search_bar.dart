import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';

class EmployeeSearchBar extends StatelessWidget {
  const EmployeeSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.buttonHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: getRegularStyle(fontSize: AppConstants.bodySize),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Search',
          hintStyle: getRegularStyle(
            fontSize: AppConstants.captionSize,
            color: ColorManager.textGrey,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: AppConstants.iconSize,
            color: ColorManager.black,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
          ),
        ),
      ),
    );
  }
}
