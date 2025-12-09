import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/storage/storage_utility.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../features/admin/navigation_admin_menu.dart';
import '../features/volunteer/navigation_volunteer_menu.dart';
import '../features/victim/navigation_victim_menu.dart';
import '../features/authentication/screens/login/login.dart';
import '../features/authentication/screens/onboarding/onboarding.dart';
// TẮT XÁC THỰC EMAIL: Không cần import VerifyEmailScreen nữa
// import '../features/authentication/screens/singup/verifi_email.dart';
import 'package:flutter/foundation.dart';

/// Helper để xử lý navigation logic sau authentication
class NavigationHelper {
  static Future<void> redirectAfterAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // TẮT XÁC THỰC EMAIL: Bỏ qua kiểm tra emailVerified
      // Cho phép user vào app ngay sau khi đăng ký
      
      // Khởi tạo storage
      await MinhLocalStorage.init(user.uid);

      // Lấy user data để check user type
      final getCurrentUserUseCase = Get.find<GetCurrentUserUseCase>();
      final currentUser = await getCurrentUserUseCase();

      final userType = currentUser?.userType;

      if (kDebugMode) {
        print('userType: ${userType?.enName}');
      }

      // Phân biệt 3 loại user: Admin, Volunteer, Victim
      if (userType != null) {
        if (userType.enName.toLowerCase() == 'admin' ||
            userType.viName.toLowerCase() == 'quản trị viên') {
          // Admin → NavigationAdminMenu
          Get.offAll(() => NavigationAdminMenu());
        } else if (userType.enName.toLowerCase() == 'volunteer' ||
            userType.viName.toLowerCase() == 'tình nguyện viên') {
          // Volunteer → NavigationVolunteerMenu
          Get.offAll(() => NavigationVolunteerMenu());
        } else {
          // Victim (nạn nhân) → NavigationVictimMenu
          Get.offAll(() => NavigationVictimMenu());
        }
      } else {
        // Default: Victim menu
        Get.offAll(() => NavigationVictimMenu());
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

