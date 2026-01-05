import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/controllers/alert_location_map_controller.dart';
import 'package:cuutrobaolu/presentation/features/common/widgets/alert_location_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class AlertLocationMapScreen extends StatelessWidget {
  final AlertEntity alert;

  const AlertLocationMapScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    // Validate that alert has coordinates
    if (alert.lat == null || alert.lng == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vị trí cảnh báo'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.location_slash,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Cảnh báo này không có thông tin vị trí',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final controller = Get.put(
      AlertLocationMapController(alertId: alert.id),
      tag: alert.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vị trí cảnh báo'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.map_1),
            onPressed: controller.openGoogleMaps,
            tooltip: 'Mở Google Maps',
          ),
        ],
      ),
      body: Obx(() {
        final currentAlert = controller.alert.value;
        if (currentAlert == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final alertLat = currentAlert.lat;
        final alertLng = currentAlert.lng;
        
        if (alertLat == null || alertLng == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.location_slash,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Cảnh báo này không có thông tin vị trí',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final alertLatLng = LatLng(alertLat, alertLng);
        double initialZoom = 13.0;

        // Adjust zoom based on radius
        final radiusKm = currentAlert.radiusKm;
        if (radiusKm != null && radiusKm > 0) {
          if (radiusKm > 10) {
            initialZoom = 10.0;
          } else if (radiusKm > 5) {
            initialZoom = 11.0;
          } else if (radiusKm > 2) {
            initialZoom = 12.0;
          } else {
            initialZoom = 13.0;
          }
        }

        return Stack(
          children: [
            // Map
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: alertLatLng,
                initialZoom: initialZoom,
              ),
              children: [
                // Tile layer
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.cuutrobaolu.app',
                ),
                // Circle layer for radius
                if (radiusKm != null && radiusKm > 0)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: alertLatLng,
                        radius: radiusKm * 1000, // Convert km to meters
                        useRadiusInMeter: true,
                        color: controller.getSeverityColor(currentAlert.severity)
                            .withOpacity(0.15),
                        borderColor: controller.getSeverityColor(currentAlert.severity)
                            .withOpacity(0.5),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                // Marker layer - reactive to current position
                GetBuilder<AlertLocationMapController>(
                  builder: (ctrl) {
                    final markers = <Marker>[
                      // Alert marker
                      Marker(
                        point: alertLatLng,
                        width: 50,
                        height: 50,
                        child: AlertLocationMarker(alert: currentAlert),
                      ),
                    ];

                    // Current location marker
                    final position = ctrl.currentPosition.value;
                    if (position != null) {
                      markers.add(
                        Marker(
                          point: LatLng(position.latitude, position.longitude),
                          width: 40,
                          height: 40,
                          child: const _CurrentLocationMarker(),
                        ),
                      );
                    }

                    return MarkerLayer(markers: markers);
                  },
                  id: 'currentPosition',
                ),
              ],
            ),

            // Info card at bottom
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _AlertInfoCard(
                controller: controller,
                alert: currentAlert,
              ),
            ),

            // Loading indicator
            GetBuilder<AlertLocationMapController>(
              builder: (ctrl) => ctrl.isLoading.value
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : const SizedBox.shrink(),
              id: 'isLoading',
            ),
          ],
        );
      }),
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
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: const Center(
        child: Icon(
          Iconsax.location,
          color: Colors.blue,
          size: 24,
        ),
      ),
    );
  }
}

/// Alert info card widget
class _AlertInfoCard extends StatelessWidget {
  final AlertLocationMapController controller;
  final AlertEntity alert;

  const _AlertInfoCard({
    required this.controller,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = controller.getSeverityColor(alert.severity);

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
                    controller.getAlertIcon(alert.alertType),
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
                          // Distance - reactive widget
                          Obx(() {
                            final distance = controller.distance.value;
                            if (distance == null) return const SizedBox.shrink();
                            return Row(
                              children: [
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
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Location info
            Builder(
              builder: (context) {
                final location = alert.location;
                if (location == null || location.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    const Icon(
                      Iconsax.map,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.openGoogleMaps,
                icon: const Icon(Iconsax.routing, size: 18),
                label: const Text('Mở Google Maps để chỉ đường'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MinhColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

