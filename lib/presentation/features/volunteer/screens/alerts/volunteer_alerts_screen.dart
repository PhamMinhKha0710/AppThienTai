import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhAlertCard.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_alerts_controller.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/alerts/widgets/alert_empty_state.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/alerts/widgets/alert_loading_skeleton.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/alerts/widgets/alert_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VolunteerAlertsScreen extends StatefulWidget {
  const VolunteerAlertsScreen({super.key});

  @override
  State<VolunteerAlertsScreen> createState() => _VolunteerAlertsScreenState();
}

class _VolunteerAlertsScreenState extends State<VolunteerAlertsScreen> {
  late final TextEditingController _searchController;
  late final VolunteerAlertsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(VolunteerAlertsController());
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _controller.search(_searchController.text);
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
          VolunteerAlertSearchBar(
            controller: _searchController,
            onChanged: (value) => controller.search(value),
          ),

          // Alerts list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const VolunteerAlertLoadingSkeleton();
              }

              final alerts = controller.currentList;
              final isAllTab = controller.selectedTab.value == 0;

              if (alerts.isEmpty) {
                return VolunteerAlertEmptyState(
                  message: isAllTab
                      ? 'Không có cảnh báo nào'
                      : 'Không có cảnh báo liên quan đến nhiệm vụ của bạn',
                  icon: isAllTab ? Iconsax.notification : Iconsax.task_square,
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


