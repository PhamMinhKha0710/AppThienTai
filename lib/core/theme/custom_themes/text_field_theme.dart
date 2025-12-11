import 'package:flutter/material.dart';

class MinhTextFormFieldTheme{
  MinhTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
      errorMaxLines: 3,
      prefixIconColor: Colors.grey,
      suffixIconColor: Colors.grey,

      labelStyle: TextStyle().copyWith(fontSize: 14, color: Colors.black),
      hintStyle: TextStyle().copyWith(fontSize: 14, color: Colors.black),
      errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),
      floatingLabelStyle: TextStyle().copyWith(color: Color.fromRGBO(0, 0, 0, 0.8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black12, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange, width: 2),
      ),

  );

  static InputDecorationTheme dartInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,

    labelStyle: TextStyle().copyWith(fontSize: 14, color: Colors.white),
    hintStyle: TextStyle().copyWith(fontSize: 14, color: Colors.white),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: TextStyle().copyWith(color: Color.fromRGBO(255, 255, 255, 0.8)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.orange, width: 2),
    ),

  );
}











