import 'dart:math' as math;
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_detail_screen.dart';
import 'package:get/get.dart';

class VictimAlertsController extends GetxController {
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  LocationService? _locationService;

  final selectedTab = 0.obs; // 0: Active, 1: History
  final activeAlerts = <AlertEntity>[].obs;
  final historyAlerts = <AlertEntity>[].obs;
  final alertsWithDistance = <AlertEntityWithDistance>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final currentPosition = Rxn<({double lat, double lng})>();

  // Filter and sort options
  final selectedSeverityFilter = Rxn<AlertSeverity>();
  final selectedTypeFilter = Rxn<AlertType>();
  final sortOption = 'severity'.obs; // 'severity', 'date', 'distance'

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    _loadCurrentLocation();
    loadAlerts();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await _locationService?.getCurrentLocation();
      if (pos != null) {
        currentPosition.value = (lat: pos.latitude, lng: pos.longitude);
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      // Load all alerts and filter by target audience
      _alertRepo.getAllAlerts().listen((allAlerts) {
        final now = DateTime.now();
        final active = <AlertEntity>[];
        final history = <AlertEntity>[];

        // Filter alerts relevant to victims
        final relevantAlerts = allAlerts.where((alert) {
          return alert.targetAudience == TargetAudience.all ||
                 alert.targetAudience == TargetAudience.victims ||
                 alert.targetAudience == TargetAudience.locationBased;
        }).toList();

        for (var alert in relevantAlerts) {
          // Check if alert is active
          final expiresAt = alert.expiresAt;
          final isActiveAlert = alert.isActive &&
              (expiresAt == null || expiresAt.isAfter(now));

          // For location-based alerts, check if user is within radius
          if (alert.targetAudience == TargetAudience.locationBased) {
            if (currentPosition.value != null && 
                alert.lat != null && 
                alert.lng != null &&
                alert.radiusKm != null) {
              final distance = _calculateDistance(
                currentPosition.value!.lat,
                currentPosition.value!.lng,
                alert.lat!,
                alert.lng!,
              );
              
              // Only show if within radius
              if (distance <= alert.radiusKm!) {
                if (isActiveAlert) {
                  active.add(alert);
                } else {
                  history.add(alert);
                }
              }
            }
          } else {
            // Show all other alerts
            if (isActiveAlert) {
              active.add(alert);
            } else {
              history.add(alert);
            }
          }
        }

        // Sort by severity and created date
        active.sort(_compareAlerts);
        history.sort(_compareAlerts);

        activeAlerts.value = active;
        historyAlerts.value = history;

        // Calculate distances for active alerts
        if (currentPosition.value != null) {
          _calculateDistances(active);
        }
      });
    } catch (e) {
      print('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateDistances(List<AlertEntity> alerts) {
    if (currentPosition.value == null) return;

    final withDistances = <AlertEntityWithDistance>[];
    
    for (var alert in alerts) {
      double? distance;
      if (alert.lat != null && alert.lng != null) {
        distance = _calculateDistance(
          currentPosition.value!.lat,
          currentPosition.value!.lng,
          alert.lat!,
          alert.lng!,
        );
      }
      withDistances.add(AlertEntityWithDistance(alert, distance));
    }

    // Sort by distance
    withDistances.sort((a, b) {
      // Prioritize by severity first
      final severityCompare = _severityToInt(b.alert.severity)
          .compareTo(_severityToInt(a.alert.severity));
      if (severityCompare != 0) return severityCompare;

      // Then by distance
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });

    alertsWithDistance.value = withDistances;
  }

  int _compareAlerts(AlertEntity a, AlertEntity b) {
    // Sort by severity (critical first)
    final severityCompare = _severityToInt(b.severity)
        .compareTo(_severityToInt(a.severity));
    if (severityCompare != 0) return severityCompare;

    // Then by created date (newest first)
    return b.createdAt.compareTo(a.createdAt);
  }

  int _severityToInt(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 4;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.low:
        return 1;
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
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

  List<AlertEntity> get currentList {
    var source = (selectedTab.value == 0 ? activeAlerts : historyAlerts).toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      source = source.where((alert) {
        return alert.title.toLowerCase().contains(query) ||
               alert.content.toLowerCase().contains(query);
      }).toList();
    }

    // Apply severity filter
    if (selectedSeverityFilter.value != null) {
      source = source.where((alert) {
        return alert.severity == selectedSeverityFilter.value;
      }).toList();
    }

    // Apply type filter
    if (selectedTypeFilter.value != null) {
      source = source.where((alert) {
        return alert.alertType == selectedTypeFilter.value;
      }).toList();
    }

    // Apply sort
    source = _applySort(source);

    return source;
  }

  List<AlertEntity> _applySort(List<AlertEntity> alerts) {
    final sort = sortOption.value;
    final sorted = List<AlertEntity>.from(alerts);

    switch (sort) {
      case 'severity':
        sorted.sort(_compareAlerts);
        break;
      case 'date':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'distance':
        if (currentPosition.value != null) {
          sorted.sort((a, b) {
            final distA = getDistance(a.id);
            final distB = getDistance(b.id);
            if (distA == null && distB == null) return 0;
            if (distA == null) return 1;
            if (distB == null) return -1;
            return distA.compareTo(distB);
          });
        } else {
          sorted.sort(_compareAlerts);
        }
        break;
      default:
        sorted.sort(_compareAlerts);
    }

    return sorted;
  }

  void filterBySeverity(AlertSeverity? severity) {
    selectedSeverityFilter.value = severity;
  }

  void filterByType(AlertType? type) {
    selectedTypeFilter.value = type;
  }

  void setSortOption(String option) {
    if (['severity', 'date', 'distance'].contains(option)) {
      sortOption.value = option;
    }
  }

  void clearFilters() {
    selectedSeverityFilter.value = null;
    selectedTypeFilter.value = null;
    sortOption.value = 'severity';
  }

  void searchAlerts(String query) {
    searchQuery.value = query;
  }

  void navigateToDetail(AlertEntity alert) {
    Get.to(() => AlertDetailScreen(alert: alert));
  }

  double? getDistance(String alertId) {
    final withDistance = alertsWithDistance.firstWhereOrNull(
      (item) => item.alert.id == alertId,
    );
    return withDistance?.distance;
  }
}

// Helper class to store alert with calculated distance
class AlertEntityWithDistance {
  final AlertEntity alert;
  final double? distance;

  AlertEntityWithDistance(this.alert, this.distance);
}
