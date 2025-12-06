import 'package:flutter/material.dart';

import '../../../../util/constants/colors.dart';
import '../../../../util/constants/sizes.dart';
import '../../../../util/device/device_utility.dart';
import '../../../../util/helpers/helper_functions.dart';

class MinhSearchContainer extends StatelessWidget {
  const MinhSearchContainer({
    super.key,
    required this.text,
    this.showBackground = true,
    this.showBorder = true,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
  });

  final String text;
  final bool showBackground, showBorder;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          padding: EdgeInsets.all(MinhSizes.md),
          width: MinhDeviceUtils.getScreenWidth(),
          decoration: BoxDecoration(
            color: showBackground ? isDark ? MinhColors.dark : MinhColors.light : Colors.transparent,
            borderRadius: BorderRadius.circular(MinhSizes.cardRadiusLg),
            border: showBorder ? Border.all(color: MinhColors.grey) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: MinhColors.darkerGrey,),
              SizedBox(width: MinhSizes.spaceBtwItems,),
              Text(text, style: Theme.of(context).textTheme.bodySmall,),
            ],
          ) ,
        ),
      ),
    );
  }
}