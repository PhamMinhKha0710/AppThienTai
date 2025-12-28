import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/core/constants/enums.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class VolunteerMapController extends GetxController {
  LocationService? _locationService;
  final RoutingService _routingService = getIt<RoutingService>();
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();

  final currentPosition = Rxn<LatLng>();
  final disasterMarkers = <Marker>[].obs;
  final shelterMarkers = <Marker>[].obs;
  final taskMarkers = <Marker>[].obs;
  final isLoading = false.obs;
  
  // Map controller for programmatic control
  final mapController = Rxn<MapController>();
  
  // Focus location (for navigating to specific task)
  final focusLocation = Rxn<LatLng>();
  
  // Route polylines for navigation
  final routePolylines = <Polyline>[].obs;
  
  // Filter state
  final activeFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    mapController.value = MapController();
    _initLocationService();
    _loadLocation();
    loadMarkers();
  }
  
  /// Focus map on a specific location
  void focusOnLocation(LatLng location, {double zoom = 15.0}) {
    focusLocation.value = location;
    mapController.value?.move(location, zoom);
  }
  
  /// Find and display route from current position to target
  Future<void> findRouteTo(LatLng target) async {
    try {
      final current = currentPosition.value;
      if (current == null) {
        print('Current position not available for routing');
        return;
      }

      final routePoints = await _routingService.getRoutePoints(current, target);
      if (routePoints != null && routePoints.isNotEmpty) {
        routePolylines.value = [
          Polyline(
            points: routePoints,
            color: Colors.blue,
            strokeWidth: 4.0,
          ),
        ];
      } else {
        print('No route found');
        routePolylines.clear();
      }
    } catch (e) {
      print('Error finding route: $e');
      routePolylines.clear();
    }
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await _locationService?.getCurrentLocation();
      if (pos != null) {
        currentPosition.value = LatLng(pos.latitude, pos.longitude);
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  Future<void> loadMarkers() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadDisasterMarkers(),
        loadShelterMarkers(),
        loadTaskMarkers(),
      ]);
    } catch (e) {
      print('Error loading markers: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void filterMarkers(String filter) {
    activeFilter.value = filter;
    // Clear markers based on filter
    if (filter == 'tasks') {
      disasterMarkers.clear();
      shelterMarkers.clear();
    } else if (filter == 'disasters') {
      taskMarkers.clear();
      shelterMarkers.clear();
    } else if (filter == 'shelters') {
      disasterMarkers.clear();
      taskMarkers.clear();
    } else {
      // Reload all
      loadMarkers();
    }
  }

  Future<void> loadDisasterMarkers() async {
    try {
      // Load high severity requests as disaster markers
      final highSeverityRequests = await _helpRequestRepo
          .getRequestsBySeverity(domain.RequestSeverity.high)
          .first;

      disasterMarkers.value = highSeverityRequests.map((req) {
        return Marker(
          point: LatLng(req.lat, req.lng),
          width: 36,
          height: 36,
          child: const Icon(Icons.warning, color: Colors.red, size: 32),
        );
      }).toList();
    } catch (e) {
      print('Error loading disaster markers: $e');
    }
  }

  Future<void> loadShelterMarkers() async {
    try {
      final shelters = await _shelterRepo.getAllShelters().first;

      shelterMarkers.value = shelters.map((shelter) {
        return Marker(
          point: LatLng(shelter.lat, shelter.lng),
          width: 36,
          height: 36,
          child: const Icon(Icons.home, color: Colors.green, size: 32),
        );
      }).toList();
    } catch (e) {
      print('Error loading shelter markers: $e');
    }
  }

  Future<void> loadTaskMarkers() async {
    try {
      // Load pending requests as task markers
      final pendingRequests = await _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.pending)
          .first;

      taskMarkers.value = pendingRequests.map((req) {
        return Marker(
          point: LatLng(req.lat, req.lng),
          width: 36,
          height: 36,
          child: const Icon(Icons.location_on, color: Colors.orange, size: 32),
        );
      }).toList();
    } catch (e) {
      print('Error loading task markers: $e');
    }
  }

  Future<void> addShelterAt(LatLng point) async {
    _showAddShelterDialog(point);
  }

  Future<void> showAddShelterForm() async {
    final pos = currentPosition.value;
    if (pos != null) {
      _showAddShelterDialog(pos);
    } else {
      Get.snackbar('Lỗi', 'Không thể lấy vị trí hiện tại');
    }
  }

  void _showAddShelterDialog(LatLng point) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final capacityController = TextEditingController(text: '50');
    final descriptionController = TextEditingController();
    final isLoading = false.obs;
    final isLoadingAddress = false.obs;

    // Auto-fill address from coordinates
    Future<void> loadAddress() async {
      isLoadingAddress.value = true;
      try {
        final address = await _locationService?.getAddressFromCoordinates(
          point.latitude,
          point.longitude,
        );
        if (address != null && address.isNotEmpty) {
          addressController.text = address;
        }
      } catch (e) {
        print('Error loading address: $e');
      } finally {
        isLoadingAddress.value = false;
      }
    }

    // Load address immediately
    loadAddress();

    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thêm điểm trú ẩn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vị trí: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên điểm trú ẩn *',
                    border: OutlineInputBorder(),
                    hintText: 'Ví dụ: Trường học ABC',
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ *',
                    border: const OutlineInputBorder(),
                    hintText: 'Ví dụ: 123 Đường ABC, Phường XYZ',
                    suffixIcon: isLoadingAddress.value
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.my_location),
                            tooltip: 'Lấy địa chỉ từ vị trí',
                            onPressed: () => loadAddress(),
                          ),
                  ),
                  maxLines: 2,
                )),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Sức chứa (người) *',
                    border: OutlineInputBorder(),
                    hintText: '50',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                    hintText: 'Thông tin thêm về điểm trú ẩn',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading.value ? null : () => Get.back(),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty ||
                                  addressController.text.trim().isEmpty ||
                                  capacityController.text.trim().isEmpty) {
                                Get.snackbar(
                                  'Lỗi',
                                  'Vui lòng điền đầy đủ thông tin bắt buộc',
                                );
                                return;
                              }

                              final capacity = int.tryParse(capacityController.text);
                              if (capacity == null || capacity <= 0) {
                                Get.snackbar(
                                  'Lỗi',
                                  'Sức chứa phải là số dương',
                                );
                                return;
                              }

                              isLoading.value = true;
                              try {
                                // Import ShelterEntity
                                final shelter = ShelterEntity(
                                  id: '', // Will be set by Firestore
                                  name: nameController.text.trim(),
                                  address: addressController.text.trim(),
                                  lat: point.latitude,
                                  lng: point.longitude,
                                  capacity: capacity,
                                  currentOccupancy: 0,
                                  isActive: true,
                                  createdAt: DateTime.now(),
                                  description: descriptionController.text.trim().isEmpty 
                                      ? null 
                                      : descriptionController.text.trim(),
                                );
                                await _shelterRepo.createShelter(shelter);
                                Get.back();
                                Get.snackbar(
                                  'Thành công',
                                  'Đã thêm điểm trú ẩn thành công!',
                                );
                                await loadShelterMarkers();
                              } catch (e) {
                                Get.snackbar(
                                  'Lỗi',
                                  'Không thể thêm điểm trú ẩn: $e',
                                );
                              } finally {
                                isLoading.value = false;
                              }
                            },
                      child: isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Thêm'),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
