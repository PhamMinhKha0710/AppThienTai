import 'package:flutter/material.dart';

class MinhCheckboxTheme {
  MinhCheckboxTheme._();

  // Light Theme
  static CheckboxThemeData ligthCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(width: 1, color: Colors.grey), // Thêm viền khi không chọn
    checkColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.black,
    ),
    fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected) ? Colors.blue : Colors.transparent,
    ),
  );

  // Dark Theme (tuỳ chỉnh màu sắc cho Dark Mode)
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(width: 1, color: Colors.grey),
    checkColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.grey[300]!,
    ),
    fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected) ? Colors.blueAccent : Colors.transparent,
    ),
  );
}











