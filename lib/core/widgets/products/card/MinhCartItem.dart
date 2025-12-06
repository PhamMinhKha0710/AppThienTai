import 'package:cuutrobaolu/core/widgets/images/MinhRoundedImage.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhBrandTitleWithVerifiedIcon.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhProductTitleText.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';  
import 'package:flutter/material.dart';

class MinhCartItem extends StatelessWidget {
  const MinhCartItem({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        MinhRoundedImage(
          imageURL: MinhImages.productImage1,
          width: 60,
          height: 60,
          backgroundColor: isDark
              ? MinhColors.darkerGrey
              : MinhColors.light,
          padding: EdgeInsets.all(MinhSizes.sm),
        ),
        SizedBox(width: MinhSizes.spaceBtwItems),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MinhBrandTitleWithVerifiedIcon(title: "Nike"),
              Flexible(
                child: MinhProductTitleText(
                  title: "Nike Air Jordan 1 Low Bred Toe",
                  maxLines: 1,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Color ",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall,
                    ),
                    TextSpan(
                      text: "Green ",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge,
                    ),
                    TextSpan(
                      text: "Size ",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall,
                    ),
                    TextSpan(
                      text: "EU 39 ",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
