import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VictimMapScreen extends StatelessWidget {
  const VictimMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimMapController());
    const fallbackVNCenter = LatLng(12.24507, 109.19432); // Nha Trang, VN

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Bản đồ thiên tai"),
        showBackArrow: true,
      ),
      body: Stack(
        children: [
          // Map
          Obx(() {
            final position = controller.currentPosition.value;
            // Ưu tiên: vị trí hiện tại -> điểm thiên tai đầu tiên -> fallback VN
            LatLng center = fallbackVNCenter;
            double zoom = 5.5;

            if (position != null) {
              center = LatLng(position.latitude, position.longitude);
              zoom = 13.0;
            } else if (controller.disasterMarkers.isNotEmpty) {
              center = controller.disasterMarkers.first.point;
              zoom = 8.5;
            }

            return FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onLongPress: (tapPosition, point) {
                  // Báo cáo thiên tai mới
                  controller.showReportDialog(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Markers cho thiên tai
                MarkerLayer(
                  markers: [
                    if (position != null)
                      // Vị trí hiện tại
                      Marker(
                        point: LatLng(position.latitude, position.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(Iconsax.location, color: Colors.blue, size: 40),
                      ),
                    // Các điểm thiên tai
                    ...controller.disasterMarkers.map((marker) => marker),
                    // Điểm trú ẩn
                    ...controller.shelterMarkers.map((marker) => marker),
                  ],
                ),
                // Polyline route nếu có
                if (controller.routePolyline != null)
                  PolylineLayer(
                    polylines: [controller.routePolyline!],
                  ),
              ],
            );
          }),

          // Controls ở trên
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(MinhSizes.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tìm điểm trú ẩn...",
                          prefixIcon: Icon(Iconsax.search_normal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                          ),
                        ),
                        onChanged: (value) => controller.searchShelter(value),
                      ),
                    ),
                    SizedBox(width: MinhSizes.spaceBtwItems),
                    PopupMenuButton<String>(
                      icon: Icon(Iconsax.filter),
                      onSelected: (value) => controller.filterDisasterType(value),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'all', child: Text('Tất cả')),
                        PopupMenuItem(value: 'flood', child: Text('Lũ lụt')),
                        PopupMenuItem(value: 'storm', child: Text('Bão')),
                        PopupMenuItem(value: 'landslide', child: Text('Sạt lở')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Legend ở dưới
          Positioned(
            bottom: 20,
            left: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(MinhSizes.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MinhMapLegendItem(icon: Iconsax.location, color: Colors.blue, label: "Vị trí bạn"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Iconsax.warning_2, color: Colors.red, label: "Thiên tai"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Iconsax.home_2, color: Colors.green, label: "Điểm trú ẩn"),
                  ],
                ),
              ),
            ),
          ),

          // Button tìm đường
          Positioned(
            bottom: 20,
            right: 10,
            child: Obx(() {
              if (controller.selectedShelter.value == null) {
                return SizedBox.shrink();
              }
              return FloatingActionButton.extended(
                onPressed: () => controller.findRoute(),
                backgroundColor: MinhColors.primary,
                icon: Icon(Iconsax.location),
                label: Text("Tìm đường"),
              );
            }),
          ),
        ],
      ),
    );
  }
}


