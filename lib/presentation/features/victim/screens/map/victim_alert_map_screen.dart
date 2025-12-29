import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_detail_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_alert_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

/// Victim Alert Map Screen - Shows alerts on a map
class VictimAlertMapScreen extends StatelessWidget {
  const VictimAlertMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimAlertMapController());
    const fallbackVNCenter = LatLng(12.24507, 109.19432); // Nha Trang, VN

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ cảnh báo'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.refreshData,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Iconsax.location),
            onPressed: controller.goToCurrentLocation,
            tooltip: 'Vị trí hiện tại',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          Obx(() {
            final position = controller.currentPosition.value;
            LatLng center = fallbackVNCenter;
            double zoom = 5.5;

            if (position != null) {
              center = LatLng(position.latitude, position.longitude);
              zoom = 12.0;
            } else if (controller.alertMarkers.isNotEmpty) {
              center = controller.alertMarkers.first.point;
              zoom = 10.0;
            }

            return FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onTap: (_, __) => controller.selectedAlert.value = null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Alert radius circles
                CircleLayer(
                  circles: controller.alertCircles,
                ),
                // Markers
                MarkerLayer(
                  markers: [
                    // Current location marker
                    if (position != null)
                      Marker(
                        point: LatLng(position.latitude, position.longitude),
                        width: 50,
                        height: 50,
                        child: const _CurrentLocationMarker(),
                      ),
                    // Alert markers
                    ...controller.alertMarkers,
                    // Shelter markers
                    ...controller.shelterMarkers,
                  ],
                ),
              ],
            );
          }),

          // Filter chips at top
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _FilterChipsRow(controller: controller),
          ),

          // Legend
          Positioned(
            bottom: 100,
            left: 10,
            child: _MapLegend(),
          ),

          // Selected alert card
          Obx(() {
            final alert = controller.selectedAlert.value;
            if (alert == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: _AlertInfoCard(
                alert: alert,
                distance: controller.getDistanceToAlert(alert),
                onViewDetails: () {
                  Get.to(() => AlertDetailScreen(alert: alert));
                },
                onNavigate: () {
                  controller.navigateToAlert(alert);
                },
                onClose: () {
                  controller.selectedAlert.value = null;
                },
              ),
            );
          }),

          // Loading indicator
          Obx(() => controller.isLoading.value
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// Current location marker widget
class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Iconsax.location,
          color: Colors.blue,
          size: 32,
        ),
      ),
    );
  }
}

/// Filter chips row widget
class _FilterChipsRow extends StatelessWidget {
  final VictimAlertMapController controller;

  const _FilterChipsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() => Row(
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected: controller.selectedFilter.value == 'all',
                    onTap: () => controller.setFilter('all'),
                    color: MinhColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Thiên tai',
                    isSelected: controller.selectedFilter.value == 'disaster',
                    onTap: () => controller.setFilter('disaster'),
                    color: Colors.red,
                    icon: Iconsax.danger,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Thời tiết',
                    isSelected: controller.selectedFilter.value == 'weather',
                    onTap: () => controller.setFilter('weather'),
                    color: Colors.blue,
                    icon: Iconsax.cloud_lightning,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Sơ tán',
                    isSelected: controller.selectedFilter.value == 'evacuation',
                    onTap: () => controller.setFilter('evacuation'),
                    color: Colors.orange,
                    icon: Iconsax.routing,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Nơi trú ẩn',
                    isSelected: controller.showShelters.value,
                    onTap: () => controller.toggleShelters(),
                    color: Colors.green,
                    icon: Iconsax.home,
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

/// Single filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Map legend widget
class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chú giải:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const MinhMapLegendItem(
              icon: Iconsax.location,
              color: Colors.blue,
              label: 'Vị trí của bạn',
            ),
            const SizedBox(height: 4),
            MinhMapLegendItem(
              icon: Iconsax.danger,
              color: Colors.red.shade700,
              label: 'Cảnh báo nghiêm trọng',
            ),
            const SizedBox(height: 4),
            MinhMapLegendItem(
              icon: Iconsax.warning_2,
              color: Colors.orange.shade700,
              label: 'Cảnh báo cao',
            ),
            const SizedBox(height: 4),
            const MinhMapLegendItem(
              icon: Iconsax.home,
              color: Colors.green,
              label: 'Nơi trú ẩn',
            ),
          ],
        ),
      ),
    );
  }
}

/// Alert info card widget (bottom sheet style)
class _AlertInfoCard extends StatelessWidget {
  final AlertEntity alert;
  final double? distance;
  final VoidCallback onViewDetails;
  final VoidCallback onNavigate;
  final VoidCallback onClose;

  const _AlertInfoCard({
    required this.alert,
    this.distance,
    required this.onViewDetails,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(alert.severity);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAlertIcon(alert.alertType),
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
                        maxLines: 1,
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
                            Icon(
                              Iconsax.location,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Colors.grey.shade600,
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
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content preview
            Text(
              alert.content,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Iconsax.document, size: 18),
                    label: const Text('Chi tiết'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Iconsax.routing, size: 18),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhColors.primary,
                      foregroundColor: Colors.white,
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

