import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_theme.dart';
import 'custom_themes/chip_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/outline_button_theme.dart';
import 'custom_themes/text_field_theme.dart';
import 'custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class MinhAppTheme{

  MinhAppTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Poppins",
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,

      appBarTheme: MinhAppBarTheme.lightAppBarTheme,
      bottomSheetTheme: MinhBottomSheetTheme.lightBottomSheetTheme,
      checkboxTheme: MinhCheckboxTheme.ligthCheckboxTheme,
      chipTheme: MinhChipDataTheme.lightChipTheme,
      elevatedButtonTheme: MinhElevatedButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: MinhOutlineButtonTheme.lightOutlinedButtonTheme,
      inputDecorationTheme: MinhTextFormFieldTheme.lightInputDecorationTheme,
      textTheme: MinhTextTheme.lightTextTheme,


  );
  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Poppins",
      brightness: Brightness.dark,
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.black,

      appBarTheme: MinhAppBarTheme.dartAppBarTheme,
      bottomSheetTheme: MinhBottomSheetTheme.dartBottomSheetTheme,
      checkboxTheme: MinhCheckboxTheme.darkCheckboxTheme,
      chipTheme: MinhChipDataTheme.dartChipTheme,
      elevatedButtonTheme: MinhElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: MinhOutlineButtonTheme.dartOutlinedButtonTheme,
      inputDecorationTheme: MinhTextFormFieldTheme.dartInputDecorationTheme,
      textTheme: MinhTextTheme.dartTextTheme,



  );

}

