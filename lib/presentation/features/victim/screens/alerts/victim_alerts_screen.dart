import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhAlertCard.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VictimAlertsScreen extends StatelessWidget {
  const VictimAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimAlertsController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Cảnh báo"),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Tabs
          Obx(() => Row(
            children: [
              Expanded(
                child: MinhTabButton(
                  label: "Đang hoạt động",
                  isSelected: controller.selectedTab.value == 0,
                  onTap: () => controller.selectedTab.value = 0,
                ),
              ),
              Expanded(
                child: MinhTabButton(
                  label: "Lịch sử",
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
                prefixIcon: Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                ),
              ),
              onChanged: (value) => controller.searchAlerts(value),
            ),
          ),

          // Alerts list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final alerts = controller.currentList;

              if (alerts.isEmpty) {
                return const Center(
                  child: Text("Không có cảnh báo nào"),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final distance = controller.getDistance(alert.id);
                  
                  return MinhAlertCard(
                    alertEntity: alert,
                    distance: distance,
                    onTap: () => controller.navigateToDetail(alert),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}


