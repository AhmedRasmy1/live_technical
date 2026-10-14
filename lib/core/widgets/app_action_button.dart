import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

/// Shared rounded button used for filter / employee / message / reset / apply.
class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = ColorManager.buttonGrey,
    this.foregroundColor = ColorManager.black,
    this.fontSize = AppConstants.bodySize,
    this.iconSize = AppConstants.iconSize,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppPadding.p16,
      vertical: AppPadding.p12,
    ),
    this.height,
    this.showLabel = true,
    this.elevated = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double? height;

  /// When false only the icon is shown (compact screens).
  final bool showLabel;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.borderRadius);
    final showText = showLabel || icon == null;

    Widget button = Tooltip(
      message: showText ? '' : label,
      child: Material(
        color: backgroundColor,
        elevation: elevated ? AppConstants.buttonElevation : 0,
        shadowColor: ColorManager.shadow,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1,
              heightFactor: height == null ? 1 : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon, size: iconSize, color: foregroundColor),
                  if (icon != null && showText)
                    const SizedBox(width: AppPadding.p8),
                  if (showText)
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          fontSize: fontSize,
                          color: foregroundColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (height != null) {
      button = SizedBox(height: height, child: button);
    }
    return button;
  }
}
