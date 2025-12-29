import 'dart:math' as math;

import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class VictimAlertMapController extends GetxController {
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();
  LocationService? _locationService;

  final MapController mapController = MapController();

  // Observable state
  final isLoading = false.obs;
  final currentPosition = Rxn<Position>();
  final alerts = <AlertEntity>[].obs;
  final shelters = <ShelterEntity>[].obs;
  final selectedAlert = Rxn<AlertEntity>();
  final selectedFilter = 'all'.obs;
  final showShelters = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    _loadData();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _loadData() async {
    isLoading.value = true;

    try {
      // Load current location
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;

      // Load alerts
      _alertRepo.getActiveAlerts().listen((alertList) {
        // Filter alerts relevant to victims
        final relevantAlerts = alertList.where((alert) {
          return alert.targetAudience == TargetAudience.all ||
              alert.targetAudience == TargetAudience.victims ||
              alert.targetAudience == TargetAudience.locationBased;
        }).toList();

        alerts.value = relevantAlerts;
      });

      // Load shelters
      _shelterRepo.getAllShelters().listen((shelterList) {
        shelters.value = shelterList;
      });
    } catch (e) {
      debugPrint('Error loading map data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  void goToCurrentLocation() {
    if (currentPosition.value != null) {
      mapController.move(
        LatLng(
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        ),
        14.0,
      );
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleShelters() {
    showShelters.value = !showShelters.value;
  }

  /// Get filtered alerts based on selected filter
  List<AlertEntity> get filteredAlerts {
    if (selectedFilter.value == 'all') {
      return alerts;
    }

    return alerts.where((alert) {
      switch (selectedFilter.value) {
        case 'disaster':
          return alert.alertType == AlertType.disaster;
        case 'weather':
          return alert.alertType == AlertType.weather;
        case 'evacuation':
          return alert.alertType == AlertType.evacuation;
        default:
          return true;
      }
    }).toList();
  }

  /// Get alert markers for the map
  List<Marker> get alertMarkers {
    return filteredAlerts
        .where((alert) => alert.lat != null && alert.lng != null)
        .map((alert) {
      return Marker(
        point: LatLng(alert.lat!, alert.lng!),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            selectedAlert.value = alert;
          },
          child: _AlertMarkerWidget(alert: alert),
        ),
      );
    }).toList();
  }

  /// Get alert circles (radius of effect) for the map
  List<CircleMarker> get alertCircles {
    return filteredAlerts
        .where((alert) =>
            alert.lat != null && alert.lng != null && alert.radiusKm != null)
        .map((alert) {
      final color = _getSeverityColor(alert.severity);
      return CircleMarker(
        point: LatLng(alert.lat!, alert.lng!),
        radius: alert.radiusKm! * 1000, // Convert km to meters
        useRadiusInMeter: true,
        color: color.withOpacity(0.15),
        borderColor: color.withOpacity(0.5),
        borderStrokeWidth: 2,
      );
    }).toList();
  }

  /// Get shelter markers for the map
  List<Marker> get shelterMarkers {
    if (!showShelters.value) return [];

    return shelters.map((shelter) {
      return Marker(
        point: LatLng(shelter.lat, shelter.lng),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () {
            _showShelterInfo(shelter);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Icon(
              Iconsax.home,
              color: Colors.green,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Calculate distance to alert
  double? getDistanceToAlert(AlertEntity alert) {
    if (currentPosition.value == null ||
        alert.lat == null ||
        alert.lng == null) {
      return null;
    }

    return _calculateDistance(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      alert.lat!,
      alert.lng!,
    );
  }

  /// Navigate to alert location using external maps app
  Future<void> navigateToAlert(AlertEntity alert) async {
    if (alert.lat == null || alert.lng == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${alert.lat},${alert.lng}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showShelterInfo(ShelterEntity shelter) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.home, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    shelter.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              shelter.address,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Sức chứa: ${shelter.capacity}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.back();
                  final url = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=${shelter.lat},${shelter.lng}',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Iconsax.routing),
                label: const Text('Chỉ đường đến đây'),
              ),
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

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}

/// Alert marker widget
class _AlertMarkerWidget extends StatelessWidget {
  final AlertEntity alert;

  const _AlertMarkerWidget({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(alert.severity);
    final icon = _getAlertIcon(alert.alertType);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
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

