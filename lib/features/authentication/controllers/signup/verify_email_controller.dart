import 'dart:async';

import 'package:cuutrobaolu/common/widgets/success_screen/SuccessScreen.dart';
import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController
{
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    sendEmailVerification();
    setTimeForAutoRedirect();
    super.onInit();
  }

  // Send email Verification link
  sendEmailVerification() async {
    try{

      final currentUser = FirebaseAuth.instance.currentUser;

      print("123");
      print('currentUser: ${currentUser.toString()}');

      await AuthenticationRepository.instance.sendEmailVerification();
      MinhLoaders.successSnackBar(
          title: "Oh Snap!",
          message: 'Please Check your inbox and verify your  email: ${currentUser?.email } '
      );
    }
    catch (e){
      MinhLoaders.errorSnackBar(
          title: "Oh Snap!",
          message: e.toString(),
      );
    }
  }

  // Timer to automatically redirect on Email Verification

  setTimeForAutoRedirect(){
    Timer.periodic(
        Duration(seconds: 1),
        (timer) async {
            await FirebaseAuth.instance.currentUser?.reload();
            final user = FirebaseAuth.instance.currentUser;
            if(user?.emailVerified ?? false)
            {
              timer.cancel();
              Get.off(
                () => SuccessScreen(
                            image: MinhImages.successfullyRegisterAnimation,
                            title: MinhTexts.yourAccountCreatedTitle,
                            subTitle: MinhTexts.yourAccountCreatedSubTitle,
                            onPressed: () => AuthenticationRepository.instance.screenRedirect()
                          ),
              );
            }
        }
    );
  }

  // Manually Check if Email Verified
  checkEmailVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    print("123");
    print('currentUser: ${currentUser.toString()}');


    if(currentUser != null && currentUser.emailVerified)
    {
      print("1234");
      Get.off(
            () => SuccessScreen(
            image: MinhImages.successfullyRegisterAnimation,
            title: MinhTexts.yourAccountCreatedTitle,
            subTitle: MinhTexts.yourAccountCreatedSubTitle,
            onPressed: () => AuthenticationRepository.instance.screenRedirect()
        ),
      );
    }
  }





}