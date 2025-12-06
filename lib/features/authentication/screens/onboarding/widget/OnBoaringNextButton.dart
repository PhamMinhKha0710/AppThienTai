import 'package:cuutrobaolu/features/authentication/controllers/onboarding/on_boarding_controller.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/device/device_utility.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnBoaringNextButton extends StatelessWidget {
  const OnBoaringNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final dark = MinhHelperFunctions.isDarkMode(context);

    return Positioned(
      bottom: MinhDeviceUtils.getAppBarHeight(),
      right: MinhSizes.defaultSpace,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          backgroundColor: dark ? MinhColors.primary : MinhColors.dark,
        ),
        onPressed: OnBoardingController.instance.nextPage,
        child: Icon(Iconsax.arrow_right_1),
      ),
    );
  }
}