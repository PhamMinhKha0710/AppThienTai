import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:flutter/material.dart';

class MinhChipDataTheme{
  MinhChipDataTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: MinhColors.grey.withOpacity(0.4),
    labelStyle: TextStyle(color: MinhColors.black),
    selectedColor: MinhColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: MinhColors.white,

  );

  static ChipThemeData dartChipTheme = ChipThemeData(
    disabledColor: MinhColors.darkerGrey,
    labelStyle: TextStyle(color: MinhColors.white),
    selectedColor: MinhColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: MinhColors.white,

  );
}










