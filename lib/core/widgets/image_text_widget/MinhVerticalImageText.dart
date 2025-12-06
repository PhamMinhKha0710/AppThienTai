import 'package:cuutrobaolu/core/widgets/images/MinhCircularImage.dart';
import 'package:flutter/material.dart';

import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';

class MinhVerticalImageText extends StatelessWidget {
  const MinhVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = MinhColors.white,
    this.backgroundColor,
    this.isNetworkImage = true,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: MinhSizes.spaceBtwItems),
        child: Column(
          children: [
            MinhCircularImage(
              image: image,
              fit: BoxFit.fitWidth,
              padding: MinhSizes.sm * 1.4,
              isNetworkImage: isNetworkImage,
              backgroundColor: backgroundColor,
              // overlayColor: isDark ? MinhColors.light : MinhColors.dark,


            ),
            SizedBox(height: MinhSizes.spaceBtwItems/2,),
            SizedBox(
              width: 55,

              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}









