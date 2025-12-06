import 'package:cuutrobaolu/domain/usecases/get_current_user_usecase.dart';
import 'package:cuutrobaolu/presentation/utils/navigation_helper.dart';
import 'package:cuutrobaolu/core/storage/storage_utility.dart';
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

  // Use Case - Clean Architecture
  GetCurrentUserUseCase? _getCurrentUserUseCase;

  @override
  void onInit() {
    super.onInit();
    // Initialize Use Case - đợi đến onReady để đảm bảo AppBindings đã hoàn tất
  }

  @override
  void onReady() {
    super.onReady();
    // Tắt splash screen ngay để UI responsive hơn
    FlutterNativeSplash.remove();
    // Initialize Use Case trong onReady để đảm bảo AppBindings đã sẵn sàng
    try {
      _getCurrentUserUseCase = Get.find<GetCurrentUserUseCase>();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting GetCurrentUserUseCase: $e');
      }
    }
    // Chạy screenRedirect async để không chặn UI
    screenRedirect();
  }

  void screenRedirect() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        if (user.emailVerified) {
          // Khởi tạo storage
          await MinhLocalStorage.init(user.uid);

          // Fetch user data using Use Case (nếu có)
          if (_getCurrentUserUseCase != null) {
            try {
              final currentUserEntity = await _getCurrentUserUseCase!();
              final userType = currentUserEntity?.userType;

              if (kDebugMode) {
                print('userType: ${userType?.enName}');
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error fetching user: $e');
              }
            }
          }

          // Use NavigationHelper for redirect
          await NavigationHelper.redirectAfterAuth();
        } else {
          // Use NavigationHelper
          await NavigationHelper.redirectAfterAuth();
        }
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


