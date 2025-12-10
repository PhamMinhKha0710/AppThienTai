import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhAlertCard.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VolunteerAlertsScreen extends StatelessWidget {
  const VolunteerAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerAlertsController());

    return Scaffold(
      appBar: AppBar(title: const Text('Cảnh báo')),
      body: Column(
        children: [
          // Tabs
          Obx(() => Row(
                children: [
                  Expanded(
                    child: MinhTabButton(
                      label: "Tất cả",
                      isSelected: controller.selectedTab.value == 0,
                      onTap: () => controller.selectedTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: MinhTabButton(
                      label: "Liên quan nhiệm vụ",
                      isSelected: controller.selectedTab.value == 1,
                      onTap: () => controller.selectedTab.value = 1,
                    ),
                  ),
                ],
              )),

          // Search bar
          Padding(
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm cảnh báo...",
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                ),
              ),
              onChanged: controller.search,
            ),
          ),

          // Alerts list
          Expanded(
            child: Obx(() {
              final alerts = controller.currentList;

              if (alerts.isEmpty) {
                return const Center(child: Text("Không có cảnh báo nào"));
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return MinhAlertCard(alert: alert);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}


