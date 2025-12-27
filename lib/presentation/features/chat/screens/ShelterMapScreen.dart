import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/presentation/features/chat/controller/ShelterMapController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class ShelterMapScreen extends StatelessWidget {
  const ShelterMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShelterMapController());
    const fallbackVNCenter = LatLng(12.24507, 109.19432); // VN fallback

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'Bản đồ nơi trú ẩn (${controller.stats['total']})',
        )),
        actions: [
          IconButton(
            icon: Icon(Iconsax.refresh),
            onPressed: () => controller.refreshShelters(),
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: Icon(Iconsax.location),
            onPressed: () => controller.loadCurrentLocation(),
            tooltip: 'Về vị trí hiện tại',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          Obx(() {
            final pos = controller.currentPosition.value;
            final focusLoc = controller.focusLocation.value;
            LatLng center = fallbackVNCenter;
            double zoom = 5.5;

            // Priority: focusLocation > currentPosition
            if (focusLoc != null) {
              center = focusLoc;
              zoom = 15.0;
            } else if (pos != null) {
              center = pos;
              zoom = 13;
            } else if (controller.shelterMarkers.isNotEmpty) {
              // Center on first shelter if available
              center = controller.shelterMarkers.first.point;
              zoom = 8.5;
            }

            return FlutterMap(
              mapController: controller.mapController.value,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onTap: (tapPosition, point) {
                  // Clear selection when tapping on map
                  controller.selectedShelter.value = null;
                },
                onLongPress: (tap, point) => controller.addShelterAt(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: [
                  // Current position marker
                  if (pos != null)
                    Marker(
                      point: pos,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Iconsax.location,
                        color: Colors.blue,
                        size: 40,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                  // Shelter markers (show filtered or all)
                  ...(controller.filterType.value != 'all'
                      ? controller.filteredShelterMarkers
                      : controller.shelterMarkers),
                ]),
              ],
            );
          }),

          // Stats overlay
          Positioned(
            top: 10,
            left: 10,
            child: Obx(() => Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      'Tổng số:',
                      '${controller.stats['total']}',
                      Colors.blue,
                    ),
                    SizedBox(height: 4),
                    _buildStatRow(
                      'Còn chỗ:',
                      '${controller.stats['available']}',
                      Colors.green,
                    ),
                    SizedBox(height: 4),
                    _buildStatRow(
                      'Đã đầy:',
                      '${controller.stats['full']}',
                      Colors.red,
                    ),
                  ],
                ),
              ),
            )),
          ),

          // Search and Filter controls
          Positioned(
            top: 10,
            right: 10,
            left: Get.width * 0.4, // Leave space for stats
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm nơi trú ẩn...',
                          prefixIcon: Icon(Iconsax.search_normal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          controller.searchQuery.value = value;
                          // controller._applyFilters();
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Obx(() => PopupMenuButton<String>(
                      icon: Icon(Iconsax.filter),
                      tooltip: 'Lọc nơi trú ẩn',
                      onSelected: (value) {
                        controller.filterMarkers(value);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.home,
                                size: 20,
                                color: controller.filterType.value == 'all'
                                    ? MinhColors.primary
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Text('Tất cả'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'available',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.home_hashtag,
                                size: 20,
                                color: controller.filterType.value == 'available'
                                    ? Colors.green
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Text('Còn chỗ'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'full',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.home_wifi,
                                size: 20,
                                color: controller.filterType.value == 'full'
                                    ? Colors.red
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Text('Đã đầy'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'nearby',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 20,
                                color: controller.filterType.value == 'nearby'
                                    ? Colors.orange
                                    : null,
                              ),
                              SizedBox(width: 8),
                              Text('Gần nhất'),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator
          Obx(() => controller.isLoading.value
              ? Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
              : SizedBox.shrink()),

          // Legend
          Positioned(
            bottom: 90,
            left: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(MinhSizes.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chú giải:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.location,
                      color: Colors.blue,
                      label: "Vị trí của bạn",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.home,
                      color: Colors.green,
                      label: "Trú ẩn còn chỗ",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.home_wifi,
                      color: Colors.red,
                      label: "Trú ẩn đã đầy",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Add shelter button
          Positioned(
            bottom: 20,
            right: 10,
            child: FloatingActionButton.extended(
              onPressed: () => controller.showAddShelterForm(),
              backgroundColor: MinhColors.primary,
              icon: Icon(Iconsax.add_square),
              label: Text('Thêm trú ẩn'),
            ),
          ),

          // Filter indicator
          Obx(() => controller.filterType.value != 'all'
              ? Positioned(
            bottom: 20,
            left: 10,
            child: Card(
              color: MinhColors.primary.withOpacity(0.9),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.filter,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _getFilterText(controller.filterType.value),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.filterMarkers('all'),
                      child: Icon(
                        Iconsax.close_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getFilterText(String filter) {
    switch (filter) {
      case 'available':
        return 'Chỉ hiển thị nơi còn chỗ';
      case 'full':
        return 'Chỉ hiển thị nơi đã đầy';
      case 'nearby':
        return 'Chỉ hiển thị nơi gần nhất';
      default:
        return '';
    }
  }
}