import 'package:cuutrobaolu/core/widgets/animations/fade_in_animation/animation_design.dart';
import 'package:cuutrobaolu/core/widgets/animations/fade_in_animation/fade_in_animation_controller.dart';
import 'package:cuutrobaolu/core/widgets/animations/fade_in_animation/fade_in_animation_model.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cuutrobaolu/core/constants/sizes.dart';
import '../login/login.dart';
import '../singup/singup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    controller.animationIn();

    var mediaQuery = MediaQuery.of(context);
    var width = mediaQuery.size.width;
    var height = mediaQuery.size.height;
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? MinhColors.secondary : MinhColors.primary,
        body: Stack(
          children: [
            MinhFadeInAnimation(
              isTwoWayAnimation: false,
              durationInMs: 1200,
              animate: MinhAnimatePosition(
                bottomAfter: 0,
                bottomBefore: -100,
                leftBefore: 0,
                leftAfter: 0,
                topAfter: 0,
                topBefore: 0,
                rightAfter: 0,
                rightBefore: 0,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(MinhSizes.defaultSpace),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Hero(
                        tag: 'welcome-images-tag',
                        child: Image(image: const AssetImage(MinhImages.minhWelcomeScreenImage), width: width * 0.7, height: height * 0.6),
                      ),
                      SizedBox(height: MinhSizes.spaceBtwSections),
                      Column(
                        children: [
                          Text(MinhTexts.minhWelcomeTitle, style: Theme.of(context).textTheme.displayMedium),
                          SizedBox(height: MinhSizes.sm),
                          Text(MinhTexts.minhWelcomeSubTitle, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                        ],
                      ),
                      SizedBox(height: MinhSizes.spaceBtwSections),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => Get.to(() => const LoginScreen()), child: Text(MinhTexts.minhLogin.toUpperCase()))),
                          const SizedBox(width: 10.0),
                          Expanded(child: ElevatedButton(onPressed: () => Get.to(() => const SignupScreen()), child: Text(MinhTexts.minhSignup.toUpperCase()))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

