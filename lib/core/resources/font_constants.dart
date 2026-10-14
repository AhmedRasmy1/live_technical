import 'package:flutter/material.dart';

class FontConstants {
  // Set a custom family here once its font assets are declared in pubspec.yaml.
  // `null` falls back to the platform default font.
  static const String? fontFamily = null;
}

class FontSize {
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
}

class FontWeightManager {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
}
