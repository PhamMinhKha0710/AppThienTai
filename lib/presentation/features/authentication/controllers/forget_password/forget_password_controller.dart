import 'package:cuutrobaolu/domain/usecases/send_password_reset_usecase.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController
{
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();

  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  // Use Case - Clean Architecture
  late final SendPasswordResetUseCase _sendPasswordResetUseCase;

  @override
  void onInit() {
    super.onInit();
    // Initialize Use Case
    _sendPasswordResetUseCase = Get.find<SendPasswordResetUseCase>();
  }

  sendPasswordResetEmail() async
  {
    try
    {
      // show loading
      MinhFullScreenLoader.openLoadingDialog(
        "Loading ............",
        MinhImages.docerAnimation,
      );

      // Kiểm Tra kết nối internet
      final isConnected = await NetworkManager.instance.isConnected();
      if(isConnected == false)
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Kiểm Tra Form
      if(! forgetPasswordFormKey.currentState!.validate())
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Gửi email đổi mật khẩu using Use Case
      await _sendPasswordResetUseCase(email.text.trim());

      // Xóa loading
      MinhFullScreenLoader.stopLoading();

      // Thành Công
      MinhLoaders.successSnackBar(
          title: "Email Sent",
          message: "Email link Sent to Reset your Password".tr
      );

      // Chuyển Trang
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));


    }
    on Failure catch (failure) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: failure.message,
      );
    }
    catch(e)
    {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: e.toString(),
      );
    }
  }

  resendPasswordResetEmail(String email) async
  {
    try
    {
      // show loading
      MinhFullScreenLoader.openLoadingDialog(
        "Loading ............",
        MinhImages.docerAnimation,
      );


      // Kiểm Tra kết nối internet
      final isConnected = await NetworkManager.instance.isConnected();
      if(isConnected == false)
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      print("email: "+ email);

      // Gửi email đổi mật khẩu using Use Case
      await _sendPasswordResetUseCase(email);

      // Xóa loading
      MinhFullScreenLoader.stopLoading();

      // Thành Công
      MinhLoaders.successSnackBar(
          title: "Email Sent",
          message: "Email link Sent to Reset your Password".tr
      );


    }
    catch(e)
    {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.successSnackBar(
        title: "Oh Snap!",
        message: e.toString(),
      );
    }
  }

}
