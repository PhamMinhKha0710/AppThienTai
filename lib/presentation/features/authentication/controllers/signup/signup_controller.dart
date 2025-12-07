import 'package:cuutrobaolu/domain/usecases/register_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/save_user_usecase.dart';
import 'package:cuutrobaolu/domain/entities/user_entity.dart' as domain;
import 'package:cuutrobaolu/presentation/utils/navigation_helper.dart';
// TẮT XÁC THỰC EMAIL: Không cần import VerifyEmailScreen nữa
// import 'package:cuutrobaolu/presentation/features/authentication/screens/singup/verifi_email.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/core/popups/full_screen_loader.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SignupController extends GetxController
{
  static SignupController get instance => Get.find();

  final hiddenPassword = true.obs;
  final privacyPolicy = true.obs;

  final email = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final userName = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final confirmPassword = TextEditingController();

  final hiddenConfirmPassword = true.obs;
  final selectedUserType = UserType.victim.obs;

  final error = RxString("");

  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  // Use Cases - Clean Architecture (lazy getters để tránh LateInitializationError)
  RegisterUseCase get _registerUseCase => Get.find<RegisterUseCase>();
  SaveUserUseCase get _saveUserUseCase => Get.find<SaveUserUseCase>();

  @override
  void onInit() {
    super.onInit();
  }

  void toggleConfirmPasswordVisibility() {
    hiddenConfirmPassword.value = !hiddenConfirmPassword.value;
  }





  // --SIGNUP // MK: 0Nempieceinh@

  Future<void> signup() async {
    try {

      error.value = "";

      // Hiển thị Loading
      MinhFullScreenLoader.openLoadingDialog(
          "Chúng tôi đang xử lý thông tin của bạn ....",
          MinhImages.docerAnimation
      );

      // Kiểm tra kết nối Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Kiểm tra Form
      if (signUpFormKey.currentState!.validate() == false) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Kiểm tra Privacy Policy
      if (privacyPolicy.value == false) {
        MinhLoaders.warningSnackBar(
          title: "Chấp nhận Chính sách bảo mật",
          message: "Để tạo tài khoản, bạn phải đọc và chấp nhận Chính sách bảo mật & Điều khoản sử dụng",
        );
        return;
      }

      // Đăng ký người dùng trên Firebase Authentication using Use Case
      final userId = await _registerUseCase(email.text.trim(), password.text.trim());

      // Tạo đối tượng UserEntity mới (domain layer)
      final newUserEntity = domain.UserEntity(
        id: userId,
        username: userName.text.trim(),
        email: email.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: "",
        userType: _convertUserType(selectedUserType.value),
        volunteerStatus: selectedUserType.value == UserType.volunteer
            ? domain.VolunteerStatus.available
            : domain.VolunteerStatus.unavailable,
        active: true,
        isVerified: false,
      );

      // Lưu thông tin người dùng using Use Case
      await _saveUserUseCase(newUserEntity);

      // Tắt Loader
      MinhFullScreenLoader.stopLoading();

      // Hiển thị thông báo thành công
      MinhLoaders.successSnackBar(
          title: "Chúc mừng",
          message: "Tài khoản của bạn đã được tạo thành công!"
      );

      // TẮT XÁC THỰC EMAIL: Không chuyển đến VerifyEmailScreen
      // Redirect trực tiếp vào app
      await NavigationHelper.redirectAfterAuth();

    } on Failure catch (failure) {
      // Tắt Loader
      MinhFullScreenLoader.stopLoading();

      // Hiển thị lỗi cho người dùng
      MinhLoaders.errorSnackBar(
          title: "Ôi không!",
          message: failure.message
      );
      error.value = failure.message;
    } catch (e) {
      // Tắt Loader
      MinhFullScreenLoader.stopLoading();

      // Hiển thị lỗi cho người dùng
      MinhLoaders.errorSnackBar(
          title: "Ôi không!",
          message: e.toString()
      );
      error.value = e.toString();
    }
  }

  // Helper để convert UserType từ core enum sang domain enum
  domain.UserType _convertUserType(UserType type) {
    switch (type) {
      case UserType.victim:
        return domain.UserType.victim;
      case UserType.volunteer:
        return domain.UserType.volunteer;
      case UserType.admin:
        return domain.UserType.admin;
    }
  }
}
