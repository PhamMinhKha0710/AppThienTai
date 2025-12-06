import 'package:cuutrobaolu/common/styles/MinhSpaceingStyle.dart';

import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class SuccessScreen extends StatelessWidget {
  const SuccessScreen(
      {
        super.key,
        required this.image,
        required this.title,
        required this.subTitle,
        required this.onPressed,
      }
  );

  final String image, title, subTitle;
  final VoidCallback onPressed;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: MinhSpaceingStyle.paddingWithApparHeight * 2,
            child: Column(
              children: [
                // Image
                if(image.contains(".json") == false)
                  Image.asset(
                      // MinhImages.deliveredEmailIllustration,flagVietNamToiYeu
                      // MinhImages.staticSuccessIllustration,
                      // MinhImages.flagVietNamToiYeu,
                      image,
                      width: MinhHelperFunctions.screenWidth() * 0.6,
                    ),
                if(image.contains(".json") == true)
                  Lottie.asset(
                    image,
                    width: MinhHelperFunctions.screenWidth() * 0.6,
                    repeat: true,        // animation lặp lại
                    animate: true,       // chạy animation
                  ),
                SizedBox(height: MinhSizes.spaceBtwSections,),

                // Title & Subtitle
                Text(
                  // MinhTexts.yourAccountCreatedTitle,
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MinhSizes.spaceBtwItems,),

                Text(
                  // MinhTexts.yourAccountCreatedSubTitle,
                  subTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MinhSizes.spaceBtwSections,),

                //Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed:
                        // (){Get.to(()=>LoginScreen());}
                        onPressed
                      ,
                      child: Text(MinhTexts.minhContinue)
                  ),
                ),


              ],
            ),
        ),
      ),
    );
  }
}
