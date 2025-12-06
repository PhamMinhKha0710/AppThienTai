import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final hidePassword = true.obs;
  final rememberMe = false.obs;

  final email = TextEditingController();
  final password = TextEditingController();

  final localStorage = GetStorage();

  GlobalKey<FormState> loginFormkey = GlobalKey<FormState>();

  final userController = Get.put(UserController());

  @override
  void onInit() {
    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? "";
    password.text = localStorage.read("REMEMBER_ME_PASSWORD") ?? "";
    super.onInit();
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
      // Show Loading
      MinhFullScreenLoader.openLoadingDialog(
        "Loading ............",
        MinhImages.docerAnimation,
      );

      // Check Internet Connectivity

      final isConnected = await NetworkManager.instance.isConnected();
      if (isConnected == false) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Check form Validation
      if (!loginFormkey.currentState!.validate()) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is select
      if (rememberMe.value) {
        localStorage.write("REMEMBER_ME_EMAIL", email.text.trim());
        localStorage.write("REMEMBER_ME_PASSWORD", password.text.trim());
      }

      // Login user using Email & Password Authentication
      final userCredentials = await AuthenticationRepository
          .instance.loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Close Loading
      MinhFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();



    } catch (e) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    }
  }


  Future<void> googleSignIn() async
  {
    try
    {
      // Show Loading
      MinhFullScreenLoader.openLoadingDialog(
        "Loading you in ..............",
        MinhImages.docerAnimation,
      );

      // Check connect Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (isConnected == false) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Google Authentication
      final userCredential = await AuthenticationRepository.instance.signInWithGoogle();

      // Save User Record
      await userController.saveUserRecord(userCredential);

      // Close loading
      MinhFullScreenLoader.stopLoading();

      // Di chuyển đên trang home
      AuthenticationRepository.instance.screenRedirect();



    }
    catch(e)
    {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
          title: 'Oh Snap!',
          message: e.toString()
      );
    }
  }




}
