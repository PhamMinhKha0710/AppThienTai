import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_tasks_controller.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/tasks/widgets/ItemTask.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VolunteerTasksScreen extends StatelessWidget {
  const VolunteerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerTasksController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadTasks,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.search_normal),
                hintText: 'Tìm nhiệm vụ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                ),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: controller.filterType.value,
                    decoration: const InputDecoration(
                      labelText: 'Loại',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(value: 'cao', child: Text('Cao')),
                      DropdownMenuItem(value: 'trung bình', child: Text('Trung bình')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.filterType.value = value;
                    },
                  ),
                ),
                SizedBox(width: MinhSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Khoảng cách (km)'),
                      Obx(() {
                        return Slider(
                          value: controller.distanceKm.value.clamp(1, 150),
                          min: 1,
                          max: 150,
                          divisions: 149,
                          label: '${controller.distanceKm.value.round()} km',
                          onChanged: (v) => controller.distanceKm.value = v,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // Tabs
            Obx(() {
              return Row(
                children: List.generate(controller.tabs.length, (index) {
                  final tab = controller.tabs[index];
                  return Expanded(
                    child: MinhTabButton(
                      label: tab == 'pending'
                          ? 'Chờ nhận'
                          : tab == 'accepted'
                              ? 'Đang làm'
                              : 'Hoàn thành',
                      isSelected: controller.selectedTab.value == index,
                      onTap: () => controller.onTabChanged(index),
                    ),
                  );
                }),
              );
            }),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // List tasks
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredTasks;
                final currentTab = controller.tabs[controller.selectedTab.value];
                
                if (list.isEmpty) {
                  // Tab-specific empty states
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            currentTab == 'pending'
                                ? Iconsax.task_square
                                : currentTab == 'accepted'
                                    ? Iconsax.document
                                    : Iconsax.tick_circle,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyTitle(currentTab),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getEmptyMessage(currentTab),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Action button
                          if (currentTab == 'accepted')
                            ElevatedButton.icon(
                              onPressed: () => controller.onTabChanged(0),
                              icon: const Icon(Iconsax.add_square),
                              label: const Text('Xem nhiệm vụ chờ nhận'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MinhColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            )
                          else if (currentTab == 'completed')
                            OutlinedButton.icon(
                              onPressed: () => controller.onTabChanged(0),
                              icon: const Icon(Iconsax.task_square),
                              label: const Text('Bắt đầu nhận nhiệm vụ'),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final task = list[index];
                    final status = task['status'];
                    return ItemTask(task: task, status: status, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyTitle(String tab) {
    switch (tab) {
      case 'pending':
        return 'Chưa có nhiệm vụ mới';
      case 'accepted':
        return 'Bạn chưa nhận nhiệm vụ nào';
      case 'completed':
        return 'Chưa có nhiệm vụ hoàn thành';
      default:
        return 'Không có dữ liệu';
    }
  }

  String _getEmptyMessage(String tab) {
    switch (tab) {
      case 'pending':
        return 'Hiện tại không có yêu cầu hỗ trợ nào.\nHãy quay lại sau hoặc thử mở rộng bán kính tìm kiếm.';
      case 'accepted':
        return 'Bạn chưa nhận nhiệm vụ nào để thực hiện.\nHãy chuyển sang tab "Chờ nhận" để xem các yêu cầu cần hỗ trợ.';
      case 'completed':
        return 'Bạn chưa hoàn thành nhiệm vụ nào.\nHãy nhận và hoàn thành nhiệm vụ để xây dựng hồ sơ tình nguyện!';
      default:
        return 'Không có thông tin';
    }
  }
}

