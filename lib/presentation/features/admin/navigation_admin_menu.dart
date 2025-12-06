
// import 'package:app_ban_hang/features/shop/screens/home/home.dart';
// import 'package:app_ban_hang/features/shop/screens/help/help.dart';
// import 'package:app_ban_hang/features/shop/screens/wishlist/wishlist.dart';
// import 'package:app_ban_hang/util/constants/colors.dart';
// import 'package:app_ban_hang/util/helpers/helper_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'features/personalization/screens/settings/settings.dart';
//
// class NavigationMenu extends StatelessWidget {
//   const NavigationMenu({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     final controller = Get.put(NavigationCotroller());
//     final isDark = MinhHelperFunctions.isDarkMode(context);
//
//     return Scaffold(
//       bottomNavigationBar: Obx(
//         () => NavigationBar(
//             selectedIndex: controller.selectedIndex.value,
//             onDestinationSelected: (value) {
//               controller.selectedIndex.value = value;
//             },
//             backgroundColor: isDark ? MinhColors.black : MinhColors.white,
//             indicatorColor: isDark
//                                     ? MinhColors.white.withOpacity(0.1)
//                                     : MinhColors.black.withOpacity(0.1) ,
//             height: 80,
//             elevation: 0,
//             destinations: [
//               NavigationDestination(icon: Icon(Iconsax.home), label: "Home"),
//               NavigationDestination(icon: Icon(Iconsax.shop), label: "Store"),
//               NavigationDestination(icon: Icon(Iconsax.heart), label: "Wishlist"),
//               NavigationDestination(icon: Icon(Iconsax.user), label: "Profile"),
//             ],
//         ),
//       ),
//       body: Obx(()=> controller.screen[controller.selectedIndex.value] ),
//     );
//   }
// }
//
//  class NavigationCotroller extends GetxController {
//   final Rx<int> selectedIndex = 0.obs;
//
//   final screen = <Widget>[
//     HomeScreen(),
//     StoreScreen(),
//     FavoriteScreen(),
//     SettingScreen(),
//   ];
// }





import 'package:cuutrobaolu/NavigationController.dart';
import 'package:cuutrobaolu/presentation/features/admin/NavigationAdminController.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationAdminMenu extends StatelessWidget {
  const NavigationAdminMenu({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(NavigationAdminController());
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
            NavigationDestination(icon: Icon(Iconsax.home), label: "Home"),
            NavigationDestination(icon: Icon(Iconsax.heart), label: "Help"),
            NavigationDestination(icon: Icon(Iconsax.shop), label: "Setting"),
            NavigationDestination(icon: Icon(Iconsax.user), label: "Profile"),
          ],
        ),
      ),
      body: Obx(()=> controller.screen[NavigationController.selectedIndex.value] ),
      // body: Obx(()=> NavigationController.screen[NavigationController.selectedIndex.value] ),
    );
  }
}






