import 'package:cuutrobaolu/features/authentication/controllers/onboarding/on_boarding_controller.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/device/device_utility.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {

  final controller = OnBoardingController.instance;

   OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {

    final dark = MinhHelperFunctions.isDarkMode(context);


    return Positioned(
      bottom: MinhDeviceUtils.getAppBarHeight() + 25,
      left: MinhSizes.defaultSpace,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(
          activeDotColor: dark ? MinhColors.light : MinhColors.dark,
          dotHeight: 6,
        ),
      ),
    );
  }
}
