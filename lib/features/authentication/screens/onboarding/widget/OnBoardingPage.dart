import 'package:flutter/material.dart';

import '../../../../../util/constants/sizes.dart';
import '../../../../../util/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage(
      {
        super.key, required this.image, required this.title, required this.subTitle
      }
      );

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MinhSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: MinhHelperFunctions.screenWidth() * 0.8,
            height: MinhHelperFunctions.screenHeight() * 0.6,
            image: AssetImage(image),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}