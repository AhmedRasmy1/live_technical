import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension ThemeHelper on BuildContext {
  /// Colors of the active theme. Falls back to the light palette when the
  /// app is not wrapped in our theme (e.g. a bare `MaterialApp` in tests).
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
