import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/buttons/MinhShortcutButton.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_home_controller.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/donation/volunteer_donation_screen.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/NavigationVolunteerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerHomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tình nguyện viên'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.refreshData(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini map
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                  child: Obx(() {
                    final position = controller.currentPosition.value;
                    final tasks = controller.nearbyTasks;
                    
                    if (position == null) {
                      return Container(
                        color: MinhColors.primary.withOpacity(0.06),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: MinhSizes.spaceBtwItems),
                              Text('Đang lấy vị trí...'),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(position.latitude, position.longitude),
                            initialZoom: 12.0,
                            onTap: (_, __) {
                              // Navigate to Map tab
                              NavigationVolunteerController.selectedIndex.value = 2;
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                // Current position
                                Marker(
                                  point: LatLng(position.latitude, position.longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Iconsax.location, color: Colors.blue, size: 36),
                                ),
                                // Nearby tasks
                                ...tasks.take(5).map((task) {
                                  final lat = task['lat'] as double?;
                                  final lng = task['lng'] as double?;
                                  if (lat != null && lng != null) {
                                    return Marker(
                                      point: LatLng(lat, lng),
                                      width: 30,
                                      height: 30,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                                    );
                                  }
                                  return null;
                                }).where((m) => m != null).cast<Marker>(),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.location, size: 16, color: MinhColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${tasks.length} nhiệm vụ gần',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwSections),

              // Stats row
              Obx(() {
                final stats = controller.stats;
                return Row(
                  children: [
                    _StatCard(
                      label: 'Ca hỗ trợ',
                      value: '${stats['tasksCompleted']}',
                      color: MinhColors.primary,
                    ),
                    SizedBox(width: MinhSizes.spaceBtwItems),
                    _StatCard(
                      label: 'Badge',
                      value: '${stats['badge']}',
                      color: Colors.orange,
                    ),
                  ],
                );
              }),
              SizedBox(height: MinhSizes.spaceBtwSections),

              // Nearby rescue requests (from real database)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Điểm cứu trợ gần', style: Theme.of(context).textTheme.titleMedium),
                  Obx(() {
                    final count = controller.nearbyTasks.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MinhColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count điểm',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: MinhColors.primary,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(MinhSizes.defaultSpace),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final tasks = controller.nearbyTasks;
                if (tasks.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(MinhSizes.defaultSpace),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.info_circle, color: Colors.grey.shade600),
                        SizedBox(width: MinhSizes.spaceBtwItems),
                        Expanded(
                          child: Text(
                            'Chưa có điểm cứu trợ gần bạn (trong bán kính 50km)',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: tasks.map((task) {
                    // Parse severity for color and icon
                    Color severityColor = Colors.orange;
                    IconData severityIcon = Iconsax.warning_2;
                    final severity = task['severity']?.toString().toLowerCase() ?? '';
                    
                    if (severity.contains('khẩn cấp') || severity.contains('urgent')) {
                      severityColor = Colors.red;
                      severityIcon = Iconsax.danger;
                    } else if (severity.contains('cao') || severity.contains('high')) {
                      severityColor = Colors.orange;
                      severityIcon = Iconsax.warning_2;
                    } else if (severity.contains('trung') || severity.contains('medium')) {
                      severityColor = Colors.yellow.shade700;
                      severityIcon = Iconsax.info_circle;
                    } else if (severity.contains('thấp') || severity.contains('low')) {
                      severityColor = Colors.green;
                      severityIcon = Iconsax.tick_circle;
                    }
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                        side: BorderSide(color: severityColor.withOpacity(0.3), width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                        onTap: () {
                          // Show task details or navigate to map
                          NavigationVolunteerController.selectedIndex.value = 2;
                        },
                        child: Padding(
                          padding: EdgeInsets.all(MinhSizes.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with severity badge
                              Row(
                                children: [
                                  Icon(severityIcon, color: severityColor, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      task['title'] ?? 'Yêu cầu cứu trợ',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: severityColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      task['severity'] ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: severityColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MinhSizes.spaceBtwItems),
                              
                              // Info rows
                              Row(
                                children: [
                                  Icon(Iconsax.tag, size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 6),
                                  Text(
                                    task['type'] ?? 'Khác',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(Iconsax.location, size: 16, color: MinhColors.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    task['distance'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: MinhColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Description if available
                              if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
                                SizedBox(height: MinhSizes.spaceBtwItems / 2),
                                Text(
                                  task['description'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              
                              SizedBox(height: MinhSizes.spaceBtwItems),
                              
                              // Accept button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.acceptTask(task),
                                  icon: const Icon(Iconsax.tick_circle, size: 18),
                                  label: const Text('Nhận nhiệm vụ'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MinhColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: MinhSizes.spaceBtwSections),

              // Call-to-action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.task_square),
                  label: const Text('Nhận nhiệm vụ'),
                  onPressed: () {
                    // Navigate to Tasks tab
                    NavigationVolunteerController.selectedIndex.value = 1;
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: MinhSizes.md),
                  ),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwSections),

              // Shortcuts
              Text('Lối tắt', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: MinhShortcutButton(
                      icon: Iconsax.home_2,
                      label: 'Đóng góp trú ẩn',
                      color: MinhColors.primary,
                      onTap: () {
                        // Navigate to Map tab (add shelter mode)
                        NavigationVolunteerController.selectedIndex.value = 2;
                        Get.snackbar(
                          'Đóng góp trú ẩn',
                          'Long press trên bản đồ để thêm điểm trú ẩn mới',
                          duration: const Duration(seconds: 3),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: MinhSizes.spaceBtwItems),
                  Expanded(
                    child: MinhShortcutButton(
                      icon: Iconsax.activity,
                      label: 'Cập nhật tình hình',
                      color: Colors.orange,
                      onTap: () {
                        // Navigate to Alerts tab
                        NavigationVolunteerController.selectedIndex.value = 3;
                      },
                    ),
                  ),
                  SizedBox(width: MinhSizes.spaceBtwItems),
                  Expanded(
                    child: MinhShortcutButton(
                      icon: Iconsax.message_question,
                      label: 'Hỗ trợ nhanh',
                      color: Colors.green,
                      onTap: () {
                        // Navigate to Support tab
                        NavigationVolunteerController.selectedIndex.value = 4;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: MinhShortcutButton(
                      icon: Iconsax.heart,
                      label: 'Quyên góp',
                      color: Colors.red,
                      onTap: () {
                        Get.to(() => VolunteerDonationScreen());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}


