import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhAlertCard.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_alerts_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/alerts/widgets/alert_empty_state.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/alerts/widgets/alert_loading_skeleton.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/alerts/widgets/alert_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VictimAlertsScreen extends StatefulWidget {
  const VictimAlertsScreen({super.key});

  @override
  State<VictimAlertsScreen> createState() => _VictimAlertsScreenState();
}

class _VictimAlertsScreenState extends State<VictimAlertsScreen> {
  late final TextEditingController _searchController;
  late final VictimAlertsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(VictimAlertsController());
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _controller.searchAlerts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

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
          AlertSearchBar(
            controller: _searchController,
            onChanged: (value) => controller.searchAlerts(value),
          ),

          // Alerts list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AlertLoadingSkeleton();
              }

              final alerts = controller.currentList;
              final isEmpty = alerts.isEmpty;
              final isActiveTab = controller.selectedTab.value == 0;

              if (isEmpty) {
                return AlertEmptyState(
                  message: isActiveTab
                      ? 'Không có cảnh báo đang hoạt động'
                      : 'Không có cảnh báo trong lịch sử',
                  icon: isActiveTab ? Iconsax.notification : Iconsax.document,
                  onRefresh: controller.loadAlerts,
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  final horizontalPadding = isTablet
                      ? MinhSizes.defaultSpace * 2
                      : MinhSizes.defaultSpace;

                  return RefreshIndicator(
                    onRefresh: controller.loadAlerts,
                    child: isTablet
                        ? GridView.builder(
                            padding: EdgeInsets.all(horizontalPadding),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: MinhSizes.spaceBtwItems,
                              mainAxisSpacing: MinhSizes.spaceBtwItems,
                            ),
                            itemCount: alerts.length,
                            itemBuilder: (context, index) {
                              final alert = alerts[index];
                              final distance = controller.getDistance(alert.id);

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 300 + (index * 50)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: MinhAlertCard(
                                  alertEntity: alert,
                                  distance: distance,
                                  onTap: () => controller.navigateToDetail(alert),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            itemCount: alerts.length,
                            itemBuilder: (context, index) {
                              final alert = alerts[index];
                              final distance = controller.getDistance(alert.id);

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 300 + (index * 50)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: MinhAlertCard(
                                  alertEntity: alert,
                                  distance: distance,
                                  onTap: () => controller.navigateToDetail(alert),
                                ),
                              );
                            },
                          ),
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


