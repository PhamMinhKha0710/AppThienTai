import 'package:cuutrobaolu/presentation/features/authentication/controllers/onboarding/on_boarding_controller.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/device_utility.dart';
import 'package:flutter/material.dart';

class OnBoardingSkip extends StatelessWidget {


  final controller = OnBoardingController.instance;

   OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MinhDeviceUtils.getAppBarHeight(),
      right: MinhSizes.defaultSpace,
      child: TextButton(onPressed: controller.skipPage, child: Text("Skip!")),
    );
  }
}
