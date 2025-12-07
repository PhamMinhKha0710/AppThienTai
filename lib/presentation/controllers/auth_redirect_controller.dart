import 'package:cuutrobaolu/presentation/utils/navigation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller để xử lý redirect sau khi app khởi động
/// Sử dụng Clean Architecture với Use Cases
class AuthRedirectController extends GetxController {
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    super.onReady();
    // Tắt splash screen ngay để UI responsive hơn
    FlutterNativeSplash.remove();
    // Chạy screenRedirect async để không chặn UI
    screenRedirect();
  }

  void screenRedirect() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // TẮT XÁC THỰC EMAIL: Bỏ qua kiểm tra emailVerified
        // Cho phép user vào app ngay
        
        // Use NavigationHelper for redirect
        await NavigationHelper.redirectAfterAuth();
      } else {
        // Use NavigationHelper
        await NavigationHelper.redirectAfterAuth();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in screenRedirect: $e');
      }
      // Fallback: redirect to login
      await NavigationHelper.redirectAfterAuth();
    }
  }
}


