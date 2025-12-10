import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class VolunteerMapScreen extends StatelessWidget {
  const VolunteerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerMapController());
    const fallbackVNCenter = LatLng(12.24507, 109.19432); // VN fallback

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadMarkers(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            final pos = controller.currentPosition.value;
            final focusLoc = controller.focusLocation.value;
            LatLng center = fallbackVNCenter;
            double zoom = 5.5;
            
            // Priority: focusLocation > currentPosition > disasterMarkers
            if (focusLoc != null) {
              center = focusLoc;
              zoom = 15.0;
            } else if (pos != null) {
              center = pos;
              zoom = 13;
            } else if (controller.disasterMarkers.isNotEmpty) {
              center = controller.disasterMarkers.first.point;
              zoom = 8.5;
            }

            return FlutterMap(
              mapController: controller.mapController.value,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onLongPress: (tap, point) => controller.addShelterAt(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: [
                  if (pos != null)
                    Marker(
                      point: pos,
                      width: 40,
                      height: 40,
                      child: const Icon(Iconsax.location, color: Colors.blue, size: 40),
                    ),
                  ...controller.disasterMarkers,
                  ...controller.taskMarkers,
                  ...controller.shelterMarkers,
                ]),
              ],
            );
          }),

          // Search and Filter controls
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          // TODO: Implement search
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Lọc',
                      onSelected: (value) {
                        controller.filterMarkers(value);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'all', child: Text('Tất cả')),
                        PopupMenuItem(value: 'tasks', child: Text('Nhiệm vụ')),
                        PopupMenuItem(value: 'disasters', child: Text('Thiên tai')),
                        PopupMenuItem(value: 'shelters', child: Text('Trú ẩn')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

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
                  children: const [
                    MinhMapLegendItem(icon: Iconsax.location, color: Colors.blue, label: "Bạn"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Icons.warning, color: Colors.red, label: "Thiên tai"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Icons.location_on, color: Colors.orange, label: "Nhiệm vụ"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Iconsax.home_2, color: Colors.green, label: "Trú ẩn"),
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
              icon: const Icon(Iconsax.home_2),
              label: const Text('Thêm trú ẩn'),
            ),
          ),
        ],
      ),
    );
  }
}


