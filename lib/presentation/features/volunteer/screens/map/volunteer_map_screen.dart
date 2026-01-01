import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_detail_screen.dart';
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
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Alert radius circles
                Obx(() => CircleLayer(
                      circles: controller.alertCircles,
                    )),
                MarkerLayer(
                  markers: [
                    if (pos != null)
                      Marker(
                        point: pos,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Iconsax.location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ...controller.disasterMarkers,
                    ...controller.taskMarkers,
                    // Alert markers (cảnh báo nguy hiểm)
                    ...controller.alertMarkers,
                    ...controller.shelterMarkers,
                  ],
                ),
                // Tuyến đường từ vị trí hiện tại tới điểm cần cứu trợ / trú ẩn
                Obx(() {
                  if (controller.routePolylines.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolylineLayer(polylines: controller.routePolylines);
                }),
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                        PopupMenuItem(
                          value: 'disasters',
                          child: Text('Thiên tai'),
                        ),
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
                    MinhMapLegendItem(
                      icon: Iconsax.location,
                      color: Colors.blue,
                      label: "Bạn",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Icons.warning,
                      color: Colors.red,
                      label: "Thiên tai",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Icons.location_on,
                      color: Colors.orange,
                      label: "Nhiệm vụ",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.warning_2,
                      color: Colors.deepOrange,
                      label: "Cảnh báo nguy hiểm",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.home_2,
                      color: Colors.green,
                      label: "Trú ẩn",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected alert marker info card
          Obx(() {
            final alert = controller.selectedAlertMarker.value;
            if (alert == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: _AlertInfoCard(
                alert: alert,
                controller: controller,
                onClose: () {
                  controller.selectedAlertMarker.value = null;
                },
              ),
            );
          }),

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

/// Alert info card widget
class _AlertInfoCard extends StatelessWidget {
  final AlertEntity alert;
  final VolunteerMapController controller;
  final VoidCallback onClose;

  const _AlertInfoCard({
    required this.alert,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(alert.severity);
    final icon = _getAlertIcon(alert.alertType);
    final distance = controller.getDistanceToAlert(alert);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: severityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alert.severity.viName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (distance != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Iconsax.location,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Location info
            if (alert.location != null)
              Row(
                children: [
                  const Icon(
                    Iconsax.map,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.location!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => AlertDetailScreen(alert: alert));
                    },
                    icon: const Icon(Iconsax.document_text, size: 18),
                    label: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (alert.lat != null && alert.lng != null) {
                        final target = LatLng(alert.lat!, alert.lng!);
                        controller.focusOnLocation(target, zoom: 15.0);
                        await controller.findRouteTo(target);
                      }
                    },
                    icon: const Icon(Iconsax.routing, size: 18),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.high:
        return Colors.orange.shade700;
      case AlertSeverity.medium:
        return Colors.amber.shade700;
      case AlertSeverity.low:
        return Colors.blue.shade700;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.disaster:
        return Iconsax.danger;
      case AlertType.weather:
        return Iconsax.cloud_lightning;
      case AlertType.evacuation:
        return Iconsax.routing;
      case AlertType.resource:
        return Iconsax.box;
      case AlertType.general:
        return Iconsax.warning_2;
    }
  }
}
