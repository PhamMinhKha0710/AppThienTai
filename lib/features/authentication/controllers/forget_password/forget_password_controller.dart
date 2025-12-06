import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController
{
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();

  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

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

      // Gửi email đỏi mk
      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

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
    catch(e)
    {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.successSnackBar(
          title: "Oh Snap!",
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

      // Gửi email đỏi mk
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

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