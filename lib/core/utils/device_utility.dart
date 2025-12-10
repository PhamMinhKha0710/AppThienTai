import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Device Utility - Helper functions for device-related operations
class MinhDeviceUtils {
  /// Get AppBar height
  static double getAppBarHeight() {
    return AppBar().preferredSize.height;
  }

  /// Get screen width
  static double getScreenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  /// Get screen height
  static double getScreenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }
}







