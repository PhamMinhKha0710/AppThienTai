import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';

import 'package:cuutrobaolu/core/constants/sizes.dart';

class MinhCircularIcon extends StatelessWidget {
  const MinhCircularIcon({
    super.key,
    this.width,
    this.height,
    this.size = MinhSizes.lg,
    this.backgroundColor,
    this.color,
    this.icon,
    this.onPressed
  });

  final double? width, height, size;
  final Color? backgroundColor, color;
  final IconData? icon;
  final VoidCallback? onPressed;



  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Container(

      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor != null
                              ? backgroundColor!
                              : isDark
                                        ? MinhColors.black.withOpacity(0.9)
                                        : MinhColors.white.withOpacity(0.9),

        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
          onPressed: onPressed,
          icon: Icon(
              icon,
              color: color,
              size: size,
          ),
      ),
    );
  }
}
