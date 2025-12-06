import 'package:cuutrobaolu/presentation/features/authentication/screens/onboarding/widget/OnBoardingDotNavigation.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/onboarding/widget/OnBoardingPage.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/onboarding/widget/OnBoardingSkip.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/onboarding/widget/OnBoaringNextButton.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:cuutrobaolu/presentation/features/authentication/controllers/onboarding/on_boarding_controller.dart';
import 'package:get/get.dart';


class OnboardingScreen extends StatelessWidget {

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                image: MinhImages.onBoardingImage1,
                title: MinhTexts.onBoardingTitle1,
                subTitle: MinhTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: MinhImages.onBoardingImage2,
                title: MinhTexts.onBoardingTitle2,
                subTitle: MinhTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: MinhImages.onBoardingImage3,
                title: MinhTexts.onBoardingTitle3,
                subTitle: MinhTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          OnBoardingSkip(),

          OnBoardingDotNavigation(),

          OnBoaringNextButton(),
        ],
      ),
    );
  }
}



 




