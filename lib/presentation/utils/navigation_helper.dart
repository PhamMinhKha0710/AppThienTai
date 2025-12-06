import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/storage/storage_utility.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../features/admin/navigation_admin_menu.dart';
import '../features/authentication/screens/login/login.dart';
import '../features/authentication/screens/onboarding/onboarding.dart';
import '../features/authentication/screens/singup/verifi_email.dart';
import '../features/shop/navigation_menu.dart';
import 'package:flutter/foundation.dart';

/// Helper để xử lý navigation logic sau authentication
class NavigationHelper {
  static Future<void> redirectAfterAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        // Khởi tạo storage
        await MinhLocalStorage.init(user.uid);

        // Lấy user data để check user type
        final getCurrentUserUseCase = Get.find<GetCurrentUserUseCase>();
        final currentUser = await getCurrentUserUseCase();

        final userType = currentUser?.userType;

        if (kDebugMode) {
          print('userType: ${userType?.enName}');
        }

        if (userType != null &&
            (userType.enName.toLowerCase() == 'admin' ||
                userType.viName.toLowerCase() == 'quản trị viên')) {
          Get.offAll(() => NavigationAdminMenu());
        } else {
          Get.offAll(() => NavigationMenu());
        }
      } else {
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
    } else {
      // Lần đầu mở app?
      final deviceStorage = GetStorage();
      deviceStorage.writeIfNull("IsFirstTime", true);
      bool isFirstTime = deviceStorage.read("IsFirstTime");

      if (isFirstTime) {
        Get.offAll(() => OnboardingScreen());
      } else {
        Get.offAll(() => LoginScreen());
      }
    }
  }
}

