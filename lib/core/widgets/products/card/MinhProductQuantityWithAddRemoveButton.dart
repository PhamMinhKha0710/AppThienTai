import 'package:cuutrobaolu/core/widgets/icons/MinhCircularIcon.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MinhProductQuantityWithAddRemoveButton extends StatelessWidget {
  const MinhProductQuantityWithAddRemoveButton({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MinhCircularIcon(
          height: 32,
          width: 32,
          size: MinhSizes.md,
          color: isDark ? MinhColors.white : MinhColors.black,
          backgroundColor: isDark ? MinhColors.darkerGrey : MinhColors.light,
          icon: Iconsax.minus,
        ),
        SizedBox(width: MinhSizes.spaceBtwItems,),
        Text(
          "9",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(width: MinhSizes.spaceBtwItems,),
        MinhCircularIcon(
          height: 32,
          width: 32,
          size: MinhSizes.md,
          color: MinhColors.white,
          backgroundColor: MinhColors.primary,
          icon: Iconsax.add,
        ),
      ],
    );
  }
}

