import 'package:flutter/material.dart';

import '../resources/color_manager.dart';
import 'app_colors.dart';

/// Builds the light and dark [ThemeData] used by `MaterialApp`.
class ThemeManager {
  const ThemeManager._();

  static ThemeData get light => _build(Brightness.light, AppColors.light);

  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: ColorManager.primary,
          brightness: brightness,
        ).copyWith(
          surface: colors.surface,
          onSurface: colors.textPrimary,
          error: ColorManager.error,
        );

    final base = ThemeData(brightness: brightness, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      dialogTheme: DialogThemeData(backgroundColor: colors.surface),
      textTheme: base.textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      extensions: [colors],
    );
  }
}
