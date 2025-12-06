import 'package:cuutrobaolu/common/styles/MinhSpaceingStyle.dart';
import 'package:cuutrobaolu/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: (){
                Get.back();
              },
              icon: Icon(CupertinoIcons.clear)
          )
        ],
      ),
      body: Padding(
          padding: MinhSpaceingStyle.paddingWithApparHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Image with 60% of screen width
              Image(
                  image: AssetImage(MinhImages.deliveredEmailIllustration,),
                  width: MinhHelperFunctions.screenWidth() * 0.6,
              ),
              SizedBox(height: MinhSizes.spaceBtwSections,),

              // Title & Subtitle
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                MinhTexts.changeYourPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MinhSizes.spaceBtwItems,),
              Text(
                MinhTexts.changeYourPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MinhSizes.spaceBtwSections,),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      Get.offAll(() => LoginScreen());
                    },
                    child: Text(
                      MinhTexts.done
                    ),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems,),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: (){
                    ForgetPasswordController.instance.resendPasswordResetEmail(email);
                  },
                  child: Text(
                      MinhTexts.resendEmail
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
