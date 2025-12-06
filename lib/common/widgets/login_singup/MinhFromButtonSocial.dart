import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/material.dart';

class MinhFromButtonSocial extends StatelessWidget {
  const MinhFromButtonSocial({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: MinhColors.grey
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {

            },
            icon: Image(
              image: AssetImage(MinhImages.facebook),
              width: MinhSizes.iconMd,
              height: MinhSizes.iconMd,
            ),
          ),
        ),
        SizedBox(width: MinhSizes.spaceBtwItems,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: MinhColors.grey
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {

            },
            icon: Image(
              image: AssetImage(MinhImages.google),
              width: MinhSizes.iconMd,
              height: MinhSizes.iconMd,
            ),
          ),
        ),
      ],
    );
  }
}
