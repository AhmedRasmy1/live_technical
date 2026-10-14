import 'package:flutter/material.dart';

import '../resources/color_manager.dart';

/// Dimmed full-area overlay with a spinner. Place it in a `Stack` and show it
/// while a save is in progress; it also blocks taps on what is below.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ColoredBox(
        color: ColorManager.overlay,
        child: Center(
          child: CircularProgressIndicator(color: ColorManager.white),
        ),
      ),
    );
  }
}
