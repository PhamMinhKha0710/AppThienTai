import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/device_utility.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class MinhTabBar extends StatelessWidget implements PreferredSizeWidget {
  const MinhTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Material(
      color: isDark ? MinhColors.black : MinhColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: MinhColors.primary,
        unselectedLabelColor: MinhColors.darkerGrey,
        labelColor: isDark ? MinhColors.white : MinhColors.primary,

        // 👇 fix khoảng thừa bên trái
        // padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.start,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(MinhDeviceUtils.getAppBarHeight());
}
