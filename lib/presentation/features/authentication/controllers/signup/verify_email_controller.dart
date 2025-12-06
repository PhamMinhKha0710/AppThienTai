import 'dart:async';

import 'package:cuutrobaolu/domain/usecases/send_email_verification_usecase.dart';
import 'package:cuutrobaolu/presentation/utils/navigation_helper.dart';
import 'package:cuutrobaolu/core/widgets/success_screen/SuccessScreen.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController
{
  static VerifyEmailController get instance => Get.find();

  // Use Case - Clean Architecture
  late final SendEmailVerificationUseCase _sendEmailVerificationUseCase;

  @override
  void onInit() {
    super.onInit();
    // Initialize Use Case
    _sendEmailVerificationUseCase = Get.find<SendEmailVerificationUseCase>();
    
    sendEmailVerification();
    setTimeForAutoRedirect();
  }

  // Send email Verification link
  sendEmailVerification() async {
    try{
      final currentUser = FirebaseAuth.instance.currentUser;

      // Use Use Case instead of repository directly
      await _sendEmailVerificationUseCase();
      
      MinhLoaders.successSnackBar(
          title: "Email đã được gửi",
          message: 'Vui lòng kiểm tra hộp thư và xác thực email: ${currentUser?.email}'
      );
    } on Failure catch (failure) {
      MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: failure.message,
      );
    } catch (e){
      MinhLoaders.errorSnackBar(
          title: "Lỗi",
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
                            onPressed: () => NavigationHelper.redirectAfterAuth()
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
            onPressed: () => NavigationHelper.redirectAfterAuth()
        ),
      );
    }
  }





}
