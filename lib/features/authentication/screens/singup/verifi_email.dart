import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/signup/verify_email_controller.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => AuthenticationRepository.instance.logout(),
            icon: Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          children: [
            // Image
            Image.asset(
              // MinhImages.deliveredEmailIllustration,flagVietNamToiYeu
              MinhImages.productsIllustration,
              // MinhImages.flagVietNamToiYeu,
              width: MinhHelperFunctions.screenWidth() * 0.6,
            ),
            SizedBox(height: MinhSizes.spaceBtwSections),

            // Title & Subtitle
            Text(
              MinhTexts.confirmEmail,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            Text(
              email ?? "Emaillllll",
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            Text(
              MinhTexts.confirmEmailSubTitle,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinhSizes.spaceBtwSections),

            //Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.checkEmailVerificationStatus(),
                child: Text(MinhTexts.minhContinue),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  controller.sendEmailVerification();
                },
                child: Text(MinhTexts.resendEmail),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
