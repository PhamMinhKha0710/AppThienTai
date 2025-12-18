import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/presentation/controllers/auth_redirect_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Splash Screen - Khởi tạo AuthRedirectController để xử lý redirect
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo AuthRedirectController - onReady() sẽ tự động được gọi
    Get.put(AuthRedirectController());

    return Scaffold(
      backgroundColor: MinhColors.primary,
      body: Center(
        child: CircularProgressIndicator(
          color: MinhColors.white,
        ),
      ),
    );
  }
}














