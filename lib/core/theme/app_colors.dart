import 'package:flutter/material.dart';

import '../resources/color_manager.dart';

/// Colors that change between light and dark mode.
/// Read them with `context.colors` (see `core/extensions/theme_helper.dart`).
/// Colors that do not change (primary, accent, error ...) stay on [ColorManager].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.fieldFill,
    required this.lightGrey,
    required this.buttonGrey,
    required this.grey,
    required this.textPrimary,
    required this.textSecondary,
  });

  /// Page background.
  final Color background;

  /// Cards, dialogs, menus and input fields.
  final Color surface;

  /// Filled chips / filter fields.
  final Color fieldFill;

  /// Avatar placeholders and secondary buttons.
  final Color lightGrey;

  /// Default button background.
  final Color buttonGrey;

  /// Icons / borders.
  final Color grey;
  final Color textPrimary;
  final Color textSecondary;

  static const AppColors light = AppColors(
    background: ColorManager.background,
    surface: ColorManager.white,
    fieldFill: ColorManager.fieldFill,
    lightGrey: ColorManager.lightGrey,
    buttonGrey: ColorManager.buttonGrey,
    grey: ColorManager.grey,
    textPrimary: ColorManager.black,
    textSecondary: ColorManager.textGrey,
  );

  static const AppColors dark = AppColors(
    background: ColorManager.darkBackground,
    surface: ColorManager.darkSurface,
    fieldFill: ColorManager.darkFieldFill,
    lightGrey: ColorManager.darkLightGrey,
    buttonGrey: ColorManager.darkButtonGrey,
    grey: ColorManager.darkGrey,
    textPrimary: ColorManager.darkTextPrimary,
    textSecondary: ColorManager.darkTextSecondary,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? fieldFill,
    Color? lightGrey,
    Color? buttonGrey,
    Color? grey,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      fieldFill: fieldFill ?? this.fieldFill,
      lightGrey: lightGrey ?? this.lightGrey,
      buttonGrey: buttonGrey ?? this.buttonGrey,
      grey: grey ?? this.grey,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      buttonGrey: Color.lerp(buttonGrey, other.buttonGrey, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
