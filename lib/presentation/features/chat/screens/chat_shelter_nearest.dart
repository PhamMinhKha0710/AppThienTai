import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/presentation/features/chat/controller/shelters_nearest_controller.dart';
import 'package:cuutrobaolu/presentation/features/chat/screens/widgets/item_shelter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChatShelterNearest extends StatelessWidget {
  const ChatShelterNearest({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SheltersNearestController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nơi trú ẩn gần nhất'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadShelters,
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
                hintText: 'Tìm nơi trú ẩn...',
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
                  child: Obx(() {
                    return DropdownButtonFormField<String>(
                      value: controller.filterType.value,
                      decoration: const InputDecoration(
                        labelText: 'Lọc theo',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                        DropdownMenuItem(value: 'available', child: Text('Còn chỗ')),
                        DropdownMenuItem(value: 'full', child: Text('Đã đầy')),
                        DropdownMenuItem(value: 'has_amenities', child: Text('Có tiện ích')),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.filterType.value = value;
                      },
                    );
                  }),
                ),
                SizedBox(width: MinhSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Khoảng cách (km)'),
                      Obx(() {
                        return Slider(
                          value: controller.distanceKm.value.clamp(1, 199),
                          min: 1,
                          max: 200,
                          divisions: 199,
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

            // Stats bar
            Obx(() {
              final stats = controller.getStats();
              return Container(
                padding: EdgeInsets.all(MinhSizes.sm),
                decoration: BoxDecoration(
                  color: MinhColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '${stats['total']}',
                      'Tổng số',
                      Iconsax.home,
                    ),
                    _buildStatItem(
                      '${stats['available']}',
                      'Còn chỗ',
                      Iconsax.tick_circle,
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      '${stats['full']}',
                      'Đã đầy',
                      Iconsax.close_circle,
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // Tabs
            Obx(() {
              return Row(
                children: List.generate(controller.tabs.length, (index) {
                  final tab = controller.tabs[index];
                  return Expanded(
                    child: MinhTabButton(
                      label: tab == 'all'
                          ? 'Tất cả'
                          : tab == 'nearest'
                          ? 'Gần nhất'
                          : 'Ưu tiên',
                      isSelected: controller.selectedTab.value == index,
                      onTap: () => controller.onTabChanged(index),
                    ),
                  );
                }),
              );
            }),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // List shelters
            Expanded(
              child: Obx(() {
                final list = controller.filteredShelters;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.home,
                          size: 60,
                          color: MinhColors.primary.withOpacity(0.5),
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems),
                        Text(
                          'Không tìm thấy nơi trú ẩn',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final shelter = list[index];
                    return ItemShelter(shelter: shelter, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.getCurrentLocationAndRecalculate();
        },
        backgroundColor: MinhColors.primary,
        child: const Icon(Iconsax.location, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon,
      {Color color = MinhColors.primary}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}