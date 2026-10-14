import 'package:flutter/material.dart';

import 'font_constants.dart';

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, Color? color) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontFamily: FontConstants.fontFamily,
  );
}

TextStyle getRegularStyle({double fontSize = FontSize.s16, Color? color}) =>
    _getTextStyle(fontSize, FontWeightManager.regular, color);

TextStyle getMediumStyle({double fontSize = FontSize.s16, Color? color}) =>
    _getTextStyle(fontSize, FontWeightManager.medium, color);

TextStyle getSemiBoldStyle({double fontSize = FontSize.s16, Color? color}) =>
    _getTextStyle(fontSize, FontWeightManager.semiBold, color);

TextStyle getBoldStyle({double fontSize = FontSize.s16, Color? color}) =>
    _getTextStyle(fontSize, FontWeightManager.bold, color);
