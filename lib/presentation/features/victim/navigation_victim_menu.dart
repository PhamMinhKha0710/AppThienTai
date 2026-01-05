import 'package:cuutrobaolu/presentation/features/victim/NavigationVictimController.dart';
import 'package:cuutrobaolu/presentation/features/victim/widgets/quick_sos_widget.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationVictimMenu extends StatelessWidget {
  const NavigationVictimMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationVictimController());
    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Scaffold(
      floatingActionButton: const QuickSOSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: NavigationVictimController.selectedIndex.value,
          onDestinationSelected: (value) {
            NavigationVictimController.selectedIndex.value = value;
          },
          backgroundColor: isDark ? MinhColors.black : MinhColors.white,
          indicatorColor: isDark
              ? MinhColors.white.withOpacity(0.1)
              : MinhColors.black.withOpacity(0.1),
          height: 80,
          elevation: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: "Trang chủ"),
            NavigationDestination(icon: Icon(Iconsax.map), label: "Bản đồ"),
            NavigationDestination(icon: Icon(Iconsax.notification), label: "Cảnh báo"),
            NavigationDestination(icon: Icon(Iconsax.message), label: "Tin nhắn"),
            NavigationDestination(icon: Icon(Iconsax.user), label: "Cá nhân"),
          ],
        ),
      ),
      body: Obx(() => controller.screen[NavigationVictimController.selectedIndex.value]),
    );
  }
}




