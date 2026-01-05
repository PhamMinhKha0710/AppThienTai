import 'dart:async';
import 'dart:math' as math;

import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertLocationMapController extends GetxController {
  final String alertId;
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  final LocationService? _locationService = getIt<LocationService>();

  final MapController mapController = MapController();

  AlertLocationMapController({required this.alertId});

  // Observable state
  final isLoading = false.obs;
  final currentPosition = Rxn<Position>();
  final distance = Rxn<double>();
  final alert = Rxn<AlertEntity>();
  
  StreamSubscription<AlertEntity?>? _alertSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupAlertListener();
    _loadCurrentLocation();
  }

  @override
  void onClose() {
    _alertSubscription?.cancel();
    super.onClose();
  }

  void _setupAlertListener() {
    _alertSubscription = _alertRepo.getAlertByIdStream(alertId).listen(
      (updatedAlert) {
        if (updatedAlert != null) {
          alert.value = updatedAlert;
          update(['currentPosition']); // Update GetBuilder for markers
          _calculateDistance();
          _focusOnAlertLocation();
        } else {
          // Alert was deleted or doesn't exist
          Get.snackbar(
            'Cảnh báo',
            'Cảnh báo này không còn tồn tại',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      onError: (error) {
        debugPrint('Error listening to alert updates: $error');
      },
    );
  }

  Future<void> _loadCurrentLocation() async {
    try {
      isLoading.value = true;
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;
      update(['currentPosition']); // Update GetBuilder
      _calculateDistance();
    } catch (e) {
      debugPrint('Error loading current location: $e');
      // Silently fail - location is optional for this feature
      // User can still see the alert location on map
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateDistance() {
    final position = currentPosition.value;
    final currentAlert = alert.value;
    
    if (position == null ||
        currentAlert == null ||
        currentAlert.lat == null ||
        currentAlert.lng == null) {
      distance.value = null;
      return;
    }

    distance.value = _calculateDistanceBetween(
      position.latitude,
      position.longitude,
      currentAlert.lat!,
      currentAlert.lng!,
    );
  }

  double _calculateDistanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
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

  void _focusOnAlertLocation() {
    final currentAlert = alert.value;
    if (currentAlert == null || currentAlert.lat == null || currentAlert.lng == null) return;

    // Wait for map to be ready
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        final alertLat = currentAlert.lat!;
        final alertLng = currentAlert.lng!;
        final alertLatLng = LatLng(alertLat, alertLng);
        double zoom = 13.0;

        // If there's a radius, adjust zoom to show it
        final radiusKm = currentAlert.radiusKm;
        if (radiusKm != null && radiusKm > 0) {
          // Calculate zoom level to show radius
          // Larger radius needs lower zoom
          if (radiusKm > 10) {
            zoom = 10.0;
          } else if (radiusKm > 5) {
            zoom = 11.0;
          } else if (radiusKm > 2) {
            zoom = 12.0;
          } else {
            zoom = 13.0;
          }
        }

        mapController.move(alertLatLng, zoom);
      } catch (e) {
        debugPrint('Error focusing on alert location: $e');
      }
    });
  }

  Future<void> openGoogleMaps() async {
    final currentAlert = alert.value;
    if (currentAlert == null || currentAlert.lat == null || currentAlert.lng == null) {
      Get.snackbar(
        'Lỗi',
        'Không có thông tin vị trí để mở bản đồ',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final alertLat = currentAlert.lat!;
    final alertLng = currentAlert.lng!;

    // Try multiple URL formats for better compatibility
    final urlConfigs = <_UrlConfig>[
      _UrlConfig(
        name: 'Google Maps Navigation',
        uri: Uri.parse('google.navigation:q=$alertLat,$alertLng'),
        mode: LaunchMode.externalApplication,
      ),
      _UrlConfig(
        name: 'Google Maps Web',
        uri: Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$alertLat,$alertLng',
        ),
        mode: LaunchMode.platformDefault,
      ),
      _UrlConfig(
        name: 'Geo URI',
        uri: Uri.parse('geo:$alertLat,$alertLng?q=$alertLat,$alertLng'),
        mode: LaunchMode.platformDefault,
      ),
      _UrlConfig(
        name: 'Google Maps Search',
        uri: Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$alertLat,$alertLng',
        ),
        mode: LaunchMode.platformDefault,
      ),
    ];

    bool launched = false;
    String? lastError;
    String? lastUrlName;

    // First, try with canLaunchUrl check
    for (final config in urlConfigs) {
      final url = config.uri;
      final urlName = config.name;
      final mode = config.mode;

      try {
        final canLaunch = await canLaunchUrl(url);
        debugPrint('[$urlName] canLaunchUrl: $canLaunch');
        
        if (canLaunch) {
          debugPrint('[$urlName] Attempting to launch: $url');
          await launchUrl(url, mode: mode);
          launched = true;
          debugPrint('[$urlName] Successfully launched');
          break;
        }
      } catch (e) {
        lastError = e.toString();
        lastUrlName = urlName;
        debugPrint('[$urlName] Error checking/launching URL: $e');
      }
    }

    // If all canLaunchUrl checks failed, try direct launch as fallback
    if (!launched) {
      debugPrint('All canLaunchUrl checks failed, trying direct launch...');
      for (final config in urlConfigs) {
        final url = config.uri;
        final urlName = config.name;
        final mode = config.mode;

        try {
          debugPrint('[$urlName] Attempting direct launch (fallback): $url');
          await launchUrl(url, mode: mode);
          launched = true;
          debugPrint('[$urlName] Successfully launched (fallback)');
          break;
        } catch (e) {
          lastError = e.toString();
          lastUrlName = urlName;
          debugPrint('[$urlName] Direct launch failed: $e');
        }
      }
    }

    if (!launched) {
      Get.snackbar(
        'Lỗi',
        'Không thể mở bản đồ. Vui lòng cài đặt Google Maps hoặc ứng dụng bản đồ khác.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      debugPrint(
        'Failed to launch any map URL. Last attempt: $lastUrlName, Error: $lastError',
      );
    }
  }

  Color getSeverityColor(AlertSeverity severity) {
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

  IconData getAlertIcon(AlertType type) {
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

/// Helper class for URL configuration
class _UrlConfig {
  final String name;
  final Uri uri;
  final LaunchMode mode;

  const _UrlConfig({
    required this.name,
    required this.uri,
    required this.mode,
  });
}

