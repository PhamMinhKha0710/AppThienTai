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
                final list = controller.filteredTasks;
                if (list.isEmpty) {
                  return const Center(child: Text('Không có nhiệm vụ.'));
                }

                if(controller.isLoading.value)
                {
                  return const Center(child: CircularProgressIndicator());
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
}


