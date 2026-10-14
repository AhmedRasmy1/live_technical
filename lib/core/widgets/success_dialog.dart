import 'dart:async';

import 'package:flutter/material.dart';

import '../resources/app_constants.dart';
import '../resources/app_padding.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

/// Success message that closes itself after [duration].
/// `await showDialog(...)` completes once it is gone.
class SuccessDialog extends StatefulWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.duration = AppConstants.successDialogDuration,
  });

  final String title;
  final String message;
  final Duration duration;

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer(widget.duration, () {
      if (mounted) Navigator.of(context).pop();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.white,
      insetPadding: const EdgeInsets.all(AppPadding.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.dialogMaxWidth,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: AppConstants.dialogIconSize,
                color: ColorManager.success,
              ),
              const SizedBox(height: AppPadding.p16),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: getMediumStyle(fontSize: AppConstants.bodySize),
              ),
              const SizedBox(height: AppPadding.p8),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: AppConstants.captionSize,
                  color: ColorManager.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
