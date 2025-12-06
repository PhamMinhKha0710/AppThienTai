import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/features/authentication/screens/singup/verifi_email.dart';
import 'package:cuutrobaolu/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/util/constants/enums.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/user/user_repository.dart';

class SignupController extends GetxController
{
  static SignupController get instance => Get.find();


  //
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

      // Đăng ký người dùng trên Firebase Authentication & lưu thông tin người dùng lên Firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(email.text.trim(), password.text.trim());


      // Tạo đối tượng UserModel mới
      final newUser = UserModel(
        id: userCredential.user!.uid,
        username: userName.text.trim(),
        email: email.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: "",
        userType: selectedUserType.value,
        volunteerStatus: selectedUserType.value == UserType.volunteer
            ? VolunteerStatus.available
            : VolunteerStatus.unavailable,
        active: true,
        isVerified: false,
      );

      // Lưu thông tin người dùng vào repository
      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserFireRecord(newUser);

      // Tắt Loader
      MinhFullScreenLoader.stopLoading();

      // Hiển thị thông báo thành công
      MinhLoaders.successSnackBar(
          title: "Chúc mừng",
          message: "Tài khoản của bạn đã được tạo! Vui lòng xác thực email để tiếp tục"
      );

      // Chuyển tới màn hình Verify Email
      Get.to(() => VerifyEmailScreen(
        email: email.text.trim(),
      ));

    } catch (e) {
      // Tắt Loader
      MinhFullScreenLoader.stopLoading();

      // Hiển thị lỗi cho người dùng
      MinhLoaders.errorSnackBar(
          title: "Ôi không!",
          message: e.toString()
      );
      error.value  = e.toString();

      print("Lỗi: " + e.toString());
    }
  }


}