import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_tasks_controller.dart';
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
                          value: controller.distanceKm.value,
                          min: 1,
                          max: 30,
                          divisions: 29,
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
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final task = list[index];
                    final status = task['status'];
                    final distance = (task['distance'] ?? 0).toString();
                    return Card(
                      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
                      child: Padding(
                        padding: EdgeInsets.all(MinhSizes.defaultSpace),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(task['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: MinhSizes.sm, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'completed'
                                        ? Colors.green.withOpacity(0.15)
                                        : status == 'accepted'
                                            ? Colors.orange.withOpacity(0.15)
                                            : MinhColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status == 'completed'
                                        ? 'Hoàn thành'
                                        : status == 'accepted'
                                            ? 'Đang làm'
                                            : 'Chờ nhận',
                                    style: TextStyle(
                                      color: status == 'completed'
                                          ? Colors.green
                                          : status == 'accepted'
                                              ? Colors.orange
                                              : MinhColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MinhSizes.spaceBtwItems / 2),
                            Text(task['desc'] ?? ''),
                            SizedBox(height: MinhSizes.spaceBtwItems / 2),
                            Row(
                              children: [
                                const Icon(Iconsax.location, size: 16),
                                SizedBox(width: 6),
                                Text(task['distanceText'] ?? 'Đang tính...'),
                              ],
                            ),
                            SizedBox(height: MinhSizes.spaceBtwItems),
                            Row(
                              children: [
                                if (status == 'pending')
                                  ElevatedButton(
                                    onPressed: () => controller.onAccept(task),
                                    child: const Text('Nhận nhiệm vụ'),
                                  ),
                                if (status == 'accepted')
                                  ElevatedButton(
                                    onPressed: () => controller.onComplete(task),
                                    child: const Text('Hoàn thành'),
                                  ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  icon: const Icon(Iconsax.map),
                                  label: const Text('Xem bản đồ'),
                                  onPressed: () => controller.viewTaskOnMap(task),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
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


