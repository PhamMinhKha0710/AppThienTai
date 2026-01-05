import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_detail_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class VictimMapScreen extends StatelessWidget {
  const VictimMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimMapController());
    const fallbackVNCenter = LatLng(12.24507, 109.19432); // Nha Trang, VN

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bản đồ thiên tai"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshMarkers(),
            tooltip: 'Làm mới',
          ),
        ],
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
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Optional radar/weather overlay
                Obx(() {
                  final url = controller.radarImageUrl.value;
                  final bounds = controller.radarBounds.value;
                  if (url == null || bounds == null)
                    return const SizedBox.shrink();
                  return OverlayImageLayer(
                    overlayImages: [
                      OverlayImage(
                        bounds: bounds,
                        imageProvider: NetworkImage(url),
                        opacity: 0.6,
                      ),
                    ],
                  );
                }),
                // OpenWeatherMap tile overlay
                Obx(() {
                  if (!controller.showOwmTiles.value)
                    return const SizedBox.shrink();
                  final template = controller.getOwmTileUrlTemplate();
                  if (template == null) return const SizedBox.shrink();
                  return Opacity(
                    opacity: controller.owmTileOpacity.value,
                    child: TileLayer(urlTemplate: template),
                  );
                }),
                // Alert radius circles
                Obx(() => CircleLayer(
                      circles: controller.alertCircles,
                    )),
                // Markers cho thiên tai
                MarkerLayer(
                  markers: [
                    if (position != null)
                      // Vị trí hiện tại
                      Marker(
                        point: LatLng(position.latitude, position.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Iconsax.location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    // Yêu cầu cứu trợ của chính user (ưu tiên hiển thị)
                    ...controller.myRequestMarkers.map((marker) => marker),
                    // Các điểm thiên tai
                    ...controller.disasterMarkers.map((marker) => marker),
                    // Alert markers (cảnh báo nguy hiểm)
                    ...controller.alertMarkers,
                    // Điểm trú ẩn
                    ...controller.shelterMarkers.map((marker) => marker),
                  ],
                ),
                // Polyline routes
                Obx(() {
                  if (controller.routePolylines.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolylineLayer(polylines: controller.routePolylines);
                }),
                // Hazard polygons (storms, flood zones, landslides)
                Obx(() {
                  if (!controller.showHazards.value ||
                      controller.hazardPolygons.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolygonLayer(polygons: controller.hazardPolygons);
                }),
                // Hazard zone markers (tap to view details)
                Obx(() {
                  if (!controller.showPredictedHazards.value ||
                      controller.hazardMarkers.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return MarkerLayer(markers: controller.hazardMarkers);
                }),
              ],
            );
          }),

          // Hazard banner & guidance
          Obx(() {
            if (!controller.showHazardBanner.value)
              return const SizedBox.shrink();
            final text = controller.hazardSummary.value ?? 'Cảnh báo nguy hiểm';
            return Positioned(
              top: 70,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.danger, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          // open guidance modal
                          Get.dialog(
                            Dialog(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hướng dẫn an toàn',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        '1. Ở yên tại vị trí an toàn nếu có thể.',
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        '2. Nếu cần di chuyển, tìm chỗ trú ẩn gần nhất bằng nút "Tìm trú ẩn".',
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        '3. Tránh khu vực lũ/đường trơn, không đi qua vùng ngập nước.',
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        '4. Liên hệ dịch vụ khẩn cấp nếu cần thiết.',
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('Đóng'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // open distribution panel
                                              controller
                                                  .toggleDistributionPanel();
                                              Get.back();
                                            },
                                            child: const Text('Tìm trú ẩn'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.back();
                                              // call emergency number
                                              final uri = Uri(
                                                scheme: 'tel',
                                                path: '112',
                                              );
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri);
                                              } else {
                                                Get.snackbar(
                                                  'Lỗi',
                                                  'Không thể gọi số khẩn cấp trên thiết bị này',
                                                );
                                              }
                                            },
                                            child: const Text('Gọi SOS'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Hướng dẫn',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Controls ở trên - Search and Filter
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(MinhSizes.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm (lũ lụt, bão, sạt lở...)",
                          prefixIcon: Icon(Iconsax.search_normal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) => controller.searchAndFilter(value),
                        onSubmitted: (value) => controller.searchAndFilter(value),
                      ),
                    ),
                    SizedBox(width: MinhSizes.spaceBtwItems),
                    // Filter dropdown
                    Obx(() => PopupMenuButton<String>(
                      icon: Icon(
                        Iconsax.filter,
                        color: controller.hasActiveFilters ? Colors.blue : null,
                      ),
                      tooltip: 'Lọc theo loại',
                      onSelected: (value) {
                        if (value == 'all') {
                          controller.setHazardTypeFilter(null);
                        } else if (value == 'shelters_only') {
                          controller.toggleSheltersOnly();
                        } else {
                          controller.setHazardTypeFilter(value);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'all', 
                          child: Row(
                            children: [
                              Icon(Icons.clear_all, color: controller.hazardTypeFilter.value == null ? Colors.blue : Colors.grey),
                              const SizedBox(width: 8),
                              Text('Tất cả', style: TextStyle(
                                fontWeight: controller.hazardTypeFilter.value == null ? FontWeight.bold : FontWeight.normal,
                              )),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'flood', 
                          child: Row(
                            children: [
                              Icon(Icons.water_drop, color: controller.hazardTypeFilter.value == 'flood' ? Colors.blue : Colors.grey),
                              const SizedBox(width: 8),
                              Text('Lũ lụt', style: TextStyle(
                                fontWeight: controller.hazardTypeFilter.value == 'flood' ? FontWeight.bold : FontWeight.normal,
                              )),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'storm', 
                          child: Row(
                            children: [
                              Icon(Icons.storm, color: controller.hazardTypeFilter.value == 'storm' ? Colors.purple : Colors.grey),
                              const SizedBox(width: 8),
                              Text('Bão', style: TextStyle(
                                fontWeight: controller.hazardTypeFilter.value == 'storm' ? FontWeight.bold : FontWeight.normal,
                              )),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'landslide', 
                          child: Row(
                            children: [
                              Icon(Icons.landscape, color: controller.hazardTypeFilter.value == 'landslide' ? Colors.brown : Colors.grey),
                              const SizedBox(width: 8),
                              Text('Sạt lở', style: TextStyle(
                                fontWeight: controller.hazardTypeFilter.value == 'landslide' ? FontWeight.bold : FontWeight.normal,
                              )),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'shelters_only', 
                          child: Row(
                            children: [
                              Icon(Icons.home, color: controller.showSheltersOnly.value ? Colors.green : Colors.grey),
                              const SizedBox(width: 8),
                              Text('Chỉ điểm trú ẩn', style: TextStyle(
                                fontWeight: controller.showSheltersOnly.value ? FontWeight.bold : FontWeight.normal,
                              )),
                            ],
                          ),
                        ),
                      ],
                    )),
                    // Clear filter button
                    Obx(() => controller.hasActiveFilters
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          tooltip: 'Xóa lọc',
                          onPressed: () => controller.clearFilters(),
                        )
                      : const SizedBox.shrink()
                    ),
                    const SizedBox(width: 8),
                    // Distribution list toggle
                    IconButton(
                      tooltip: 'Danh sách điểm phân phối',
                      icon: const Icon(Icons.list),
                      onPressed: () => controller.toggleDistributionPanel(),
                    ),
                    const SizedBox(width: 8),
                    // Weather/Overlay settings button
                    IconButton(
                      tooltip: 'Radar / Thời tiết',
                      icon: const Icon(Icons.cloud),
                      onPressed: () {
                        final apiController = TextEditingController(
                          text: controller.owmApiKey.value,
                        );
                        String selectedLayer =
                            controller.selectedOwmLayer.value;
                        double opacity = controller.owmTileOpacity.value;
                        bool showTiles = controller.showOwmTiles.value;

                        Get.dialog(
                          Dialog(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  width: 360,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Cấu hình Overlay thời tiết',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: apiController,
                                        decoration: const InputDecoration(
                                          labelText: 'OpenWeatherMap API key',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text('Layer: '),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: selectedLayer,
                                              items: controller
                                                  .availableOwmLayers
                                                  .map((layer) {
                                                    return DropdownMenuItem(
                                                      value: layer,
                                                      child: Text(layer),
                                                    );
                                                  })
                                                  .toList(),
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(
                                                  () => selectedLayer = v,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text('Hiển thị'),
                                          const Spacer(),
                                          Switch.adaptive(
                                            value: showTiles,
                                            onChanged: (v) =>
                                                setState(() => showTiles = v),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text('Độ mờ'),
                                          Expanded(
                                            child: Slider(
                                              value: opacity,
                                              min: 0.0,
                                              max: 1.0,
                                              divisions: 10,
                                              onChanged: (v) =>
                                                  setState(() => opacity = v),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('Hủy'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              controller.setOwmApiKey(
                                                apiController.text.trim(),
                                              );
                                              controller.setSelectedOwmLayer(
                                                selectedLayer,
                                              );
                                              controller.setOwmOpacity(opacity);
                                              controller.toggleShowOwmTiles(
                                                showTiles,
                                              );
                                              Get.back();
                                            },
                                            child: const Text('Lưu'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
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
                    MinhMapLegendItem(
                      icon: Iconsax.location,
                      color: Colors.blue,
                      label: "Vị trí bạn",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.warning_2,
                      color: Colors.orange,
                      label: "Yêu cầu của tôi",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.danger,
                      color: Colors.red,
                      label: "Thiên tai",
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.warning_2,
                      color: Colors.deepOrange,
                      label: "Cảnh báo nguy hiểm",
                    ),
                    SizedBox(height: 4),
                    // Toggle hiển thị vùng nguy hiểm
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Hiện vùng nguy hiểm',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            value: controller.showHazards.value,
                            onChanged: (v) => controller.showHazards.value = v,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    MinhMapLegendItem(
                      icon: Iconsax.home_2,
                      color: Colors.green,
                      label: "Điểm trú ẩn",
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

/// Alert info card widget
class _AlertInfoCard extends StatelessWidget {
  final AlertEntity alert;
  final VictimMapController controller;
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
                        await controller.findRouteTo(
                          LatLng(alert.lat!, alert.lng!),
                        );
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
