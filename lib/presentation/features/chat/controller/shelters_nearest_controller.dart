import 'dart:async';
import 'package:cuutrobaolu/data/repositories/MinhTest/sheltersRepository.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:cuutrobaolu/presentation/features/chat/screens/ShelterMapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';

class SheltersNearestController extends GetxController {
  final SheltersRepository _sheltersRepo = SheltersRepository();

  LocationService? _locationService;
  RoutingService? _routingService;

  final filterType = 'all'.obs;
  final distanceKm = 150.0.obs;
  final searchQuery = ''.obs;

  final tabs = const ['all', 'nearest', 'priority'];
  final selectedTab = 0.obs;

  final shelters = <ShelterEntity>[].obs;
  final shelterDistances = <String, double>{}.obs;
  final shelterDistanceTexts = <String, String>{}.obs;

  final isLoading = false.obs;
  final isCalculatingDistances = false.obs;
  Position? currentPosition;

  StreamSubscription<List<ShelterEntity>>? _shelterSub;

  @override
  void onInit() {
    super.onInit();
    _initServices();
    listenSheltersRealtime();
    ever(selectedTab, (_) => listenSheltersRealtime());
  }

  @override
  void onClose() {
    _shelterSub?.cancel();
    super.onClose();
  }

  void _initServices() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }

    try {
      _routingService = Get.find<RoutingService>();
    } catch (_) {
      _routingService = Get.put(RoutingService(), permanent: true);
    }
  }

  void listenSheltersRealtime() {
    _shelterSub?.cancel();
    isLoading.value = true;

    final stream = _sheltersRepo.getNearestSheltersStream();

    _shelterSub = stream.listen(
          (shelterList) async {
        shelters.value = shelterList;

        // Get current location if not available
        if (currentPosition == null) {
          await getCurrentLocation();
        }

        // Calculate distances if we have location
        if (currentPosition != null) {
          await _calculateDistancesInBackground(currentPosition!, shelterList);
        }

        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        print('Realtime error: $e');
        MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Không thể tải danh sách trú ẩn: $e",
        );
      },
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      if (_locationService == null) {
        _initServices();
      }

      final hasPermission = await _locationService?.checkLocationPermission() ?? false;
      if (!hasPermission) {
        print('Location permission not granted');
        return;
      }

      currentPosition = await _locationService?.getCurrentLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Location request timeout');
          return null;
        },
      );

      if (currentPosition != null) {
        print('Current location: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> getCurrentLocationAndRecalculate() async {
    await getCurrentLocation();
    if (currentPosition != null && shelters.isNotEmpty) {
      await _calculateDistancesInBackground(currentPosition!, shelters);
    }
  }

  Future<void> _calculateDistancesInBackground(
      Position currentPos,
      List<ShelterEntity> sheltersList,
      ) async {
    if (_routingService == null) {
      print('RoutingService is null, cannot calculate distances');
      for (var shelter in sheltersList) {
        shelterDistanceTexts[shelter.id] = 'Không thể tính';
      }
      return;
    }

    isCalculatingDistances.value = true;

    print('Calculating routing distances for ${sheltersList.length} shelters');

    final futures = sheltersList.map((shelter) async {
      final shelterId = shelter.id;

      print('Calculating distance to shelter $shelterId at: ${shelter.lat}, ${shelter.lng}');

      try {
        final routeDistance = await _routingService!.getRouteDistance(
          currentPos.latitude,
          currentPos.longitude,
          shelter.lat,
          shelter.lng,
        );

        String distanceText;
        if (routeDistance != null) {
          print('Shelter $shelterId distance: $routeDistance km');
          if (routeDistance < 1) {
            distanceText = '${(routeDistance * 1000).round()} m';
          } else if (routeDistance < 10) {
            distanceText = '${routeDistance.toStringAsFixed(1)} km';
          } else {
            distanceText = '${routeDistance.round()} km';
          }

          // Store distances
          shelterDistances[shelterId] = routeDistance;
          shelterDistanceTexts[shelterId] = distanceText;
        } else {
          print('Shelter $shelterId: route distance is null');
          shelterDistanceTexts[shelterId] = 'Không xác định';
        }
      } catch (e) {
        print('Error calculating route distance for shelter $shelterId: $e');
        shelterDistanceTexts[shelterId] = 'Lỗi tính toán';
      }

      return shelter;
    }).toList();

    await Future.wait(futures);
    isCalculatingDistances.value = false;
    print('All shelter distance calculations completed');

    // Refresh UI
    shelters.refresh();
  }

  String getShelterDistanceText(String shelterId) {
    return shelterDistanceTexts[shelterId] ?? 'Đang tính...';
  }

  double? getShelterDistance(String shelterId) {
    return shelterDistances[shelterId];
  }

  List<ShelterEntity> get filteredShelters {
    print('=== FILTERING SHELTERS START ===');
    print('Total shelters: ${shelters.length}');
    print('Filter type: ${filterType.value}');
    print('Distance limit: ${distanceKm.value} km');

    var filtered = List<ShelterEntity>.from(shelters);

    // Filter by type
    if (filterType.value != 'all') {
      filtered = filtered.where((shelter) {
        switch (filterType.value) {
          case 'available':
            return !shelter.isFull;
          case 'full':
            return shelter.isFull;
          case 'has_amenities':
            return shelter.amenities != null && shelter.amenities!.isNotEmpty;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by distance
    if (distanceKm.value > 0 && currentPosition != null) {
      filtered = filtered.where((shelter) {
        final distance = getShelterDistance(shelter.id);
        return distance == null || distance <= distanceKm.value;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((shelter) {
        final name = shelter.name.toLowerCase();
        final address = shelter.address.toLowerCase();
        final description = shelter.description?.toLowerCase() ?? '';
        return name.contains(query) ||
            address.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Sort based on selected tab
    filtered.sort((a, b) {
      switch (tabs[selectedTab.value]) {
        case 'nearest':
          final distA = getShelterDistance(a.id) ?? double.infinity;
          final distB = getShelterDistance(b.id) ?? double.infinity;
          return distA.compareTo(distB);

        case 'priority':
        // Priority: available slots, then distance
          final slotsA = a.availableSlots;
          final slotsB = b.availableSlots;
          if (slotsA != slotsB) {
            return slotsB.compareTo(slotsA); // More slots first
          }
          final distA = getShelterDistance(a.id) ?? double.infinity;
          final distB = getShelterDistance(b.id) ?? double.infinity;
          return distA.compareTo(distB);

        default: // 'all'
        // Default: sort by distance
          final distA = getShelterDistance(a.id) ?? double.infinity;
          final distB = getShelterDistance(b.id) ?? double.infinity;
          return distA.compareTo(distB);
      }
    });

    print('=== FILTERING SHELTERS END: ${filtered.length} shelters ===');
    return filtered;
  }

  Map<String, int> getStats() {
    final total = shelters.length;
    final available = shelters.where((s) => !s.isFull).length;
    final full = shelters.where((s) => s.isFull).length;

    return {
      'total': total,
      'available': available,
      'full': full,
    };
  }

  Future<void> loadShelters() async {
    isLoading.value = true;
    try {
      final sheltersList = await _sheltersRepo.getNearestShelters();

      var filtered = sheltersList.map((dto) => dto.toEntity()).toList();


      print('=== FILTERING SHELTERS START ===');
      print('Total shelters: ${filtered.length}');
      shelters.value = filtered;

      if (currentPosition == null) {
        await getCurrentLocation();
      }

      if (currentPosition != null) {
        await _calculateDistancesInBackground(currentPosition!, filtered);
      }
    } catch (e) {
      print('Error loading shelters: $e');
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể tải danh sách trú ẩn: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
    shelters.refresh(); // Trigger UI update
  }

  void navigateToShelter(ShelterEntity shelter) {
    // Implement navigation logic
    Get.dialog(
      AlertDialog(
        title: Text('Mở Google Maps?'),
        content: Text('Bạn muốn mở chỉ đường đến "${shelter.name}" trong Google Maps?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Open Google Maps with directions
              final url = 'https://www.google.com/maps/dir/?api=1&destination=${shelter.lat},${shelter.lng}';
              // Use url_launcher package to open URL
              // launchUrl(Uri.parse(url));
              MinhLoaders.successSnackBar(
                title: 'Thành công',
                message: 'Đang mở Google Maps...',
              );
            },
            child: Text('Mở Maps'),
          ),
        ],
      ),
    );
  }

  void viewShelterOnMap(ShelterEntity shelter) {
    // Navigate to map screen with shelter location
    // Get.toNamed('/map', arguments: {
    //   'lat': shelter.lat,
    //   'lng': shelter.lng,
    //   'title': shelter.name,
    //   'type': 'shelter',
    // });

    Get.to(() =>  ShelterMapScreen(), arguments:{
      'lat': shelter.lat,
      'lng': shelter.lng,
      'title': shelter.name,
    });
  }
}