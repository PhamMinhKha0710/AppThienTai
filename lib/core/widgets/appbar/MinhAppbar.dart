import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/device_utility.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MinhAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MinhAppbar(
      {
        super.key,
        this.title,
        this.showBackArrow = false,
        this.leadingIcon,
        this.action,
        this.leadingOnPressed
      }
  );

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? action;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);
    return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: MinhSizes.md),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: showBackArrow
                                  ? IconButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        icon: Icon(
                                            Iconsax.arrow_left,
                                            color: isDark
                                                            ? MinhColors.white
                                                            : MinhColors.black,
                                        )
                                  )
                                  : leadingIcon != null
                                                        ? IconButton(
                                                            onPressed: leadingOnPressed,
                                                            icon: Icon(
                                                                leadingIcon,
                                                                color: isDark
                                                                              ? MinhColors.white
                                                                              : MinhColors.black,
                                                            ),
                                                          )
                                                        : null,
          title: title,
          actions: action,
        ),
        );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(MinhDeviceUtils.getAppBarHeight() );
}
