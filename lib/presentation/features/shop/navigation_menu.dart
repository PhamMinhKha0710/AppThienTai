

import 'package:cuutrobaolu/NavigationController.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(NavigationController());
    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          selectedIndex: NavigationController.selectedIndex.value,
          onDestinationSelected: (value) {
            NavigationController.selectedIndex.value = value;
          },
          backgroundColor: isDark ? MinhColors.black : MinhColors.white,
          indicatorColor: isDark
              ? MinhColors.white.withOpacity(0.1)
              : MinhColors.black.withOpacity(0.1) ,
          height: 80,
          elevation: 0,
          destinations: [
            NavigationDestination(icon: Icon(Iconsax.home), label: "Trang chủ"),
            NavigationDestination(icon: Icon(Iconsax.message_question), label: "Yêu cầu"),
            NavigationDestination(icon: Icon(Iconsax.heart), label: "Hỗ trợ"),
            NavigationDestination(icon: Icon(Iconsax.user), label: "Cá nhân"),
          ],
        ),
      ),
      body: Obx(()=> controller.screen[NavigationController.selectedIndex.value] ),
      // body: Obx(()=> NavigationController.screen[NavigationController.selectedIndex.value] ),
    );
  }
}





