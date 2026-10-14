import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/resources/app_constants.dart';
import '../../../../core/resources/app_padding.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/styles_manager.dart';

/// "Creating Messaging Channels" + info tooltip + yellow switch.
class MessagingToggleRow extends StatelessWidget {
  const MessagingToggleRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            'Creating Messaging Channels',
            style: getRegularStyle(fontSize: AppConstants.captionSize),
          ),
        ),
        const SizedBox(width: AppPadding.p4),
        const Tooltip(
          message: 'You Can Chat With Team Through Project Board',
          triggerMode: TooltipTriggerMode.tap,
          child: Icon(
            Icons.info,
            size: AppConstants.smallIconSize,
            color: ColorManager.black,
          ),
        ),
        const SizedBox(width: AppPadding.p16),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: ColorManager.accent,
        ),
      ],
    );
  }
}
