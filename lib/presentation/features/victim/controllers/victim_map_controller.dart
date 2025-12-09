import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class VictimMapController extends GetxController {
  LocationService? _locationService;
  
  final currentPosition = Rxn<Position>();
  final disasterMarkers = <Marker>[].obs;
  final shelterMarkers = <Marker>[].obs;
  final selectedShelter = Rxn<Map<String, dynamic>>();
  Polyline? routePolyline;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    getCurrentLocation();
    loadDisasterMarkers();
    loadShelterMarkers();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }
    final position = await _locationService?.getCurrentLocation();
    currentPosition.value = position;
  }

  void loadDisasterMarkers() {
    // TODO: Load from Firestore
    disasterMarkers.value = [
      Marker(
        point: LatLng(10.762622, 106.660172), // Example coordinates
        width: 40,
        height: 40,
        child: Icon(Icons.warning, color: Colors.red, size: 40),
      ),
    ];
  }

  void loadShelterMarkers() {
    // TODO: Load from Firestore
    shelterMarkers.value = [
      Marker(
        point: LatLng(10.772622, 106.670172), // Example coordinates
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            selectedShelter.value = {
              'name': 'Trường học X',
              'available': 50,
              'capacity': 100,
              'lat': 10.772622,
              'lng': 106.670172,
            };
          },
          child: Icon(Icons.home, color: Colors.green, size: 40),
        ),
      ),
    ];
  }

  void searchShelter(String query) {
    // TODO: Implement search
  }

  void filterDisasterType(String type) {
    // TODO: Implement filter
  }

  void findRoute() {
    if (currentPosition.value == null || selectedShelter.value == null) return;
    
    // TODO: Calculate route using Google Directions API or similar
    final start = LatLng(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
    );
    final end = LatLng(
      selectedShelter.value!['lat'],
      selectedShelter.value!['lng'],
    );
    
    routePolyline = Polyline(
      points: [start, end],
      strokeWidth: 3,
      color: Colors.blue,
    );
    update();
  }

  void showReportDialog(LatLng point) {
    Get.dialog(
      AlertDialog(
        title: Text('Báo cáo thiên tai'),
        content: Text('Bạn muốn báo cáo thiên tai tại vị trí này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to report screen
              Get.back();
            },
            child: Text('Báo cáo'),
          ),
        ],
      ),
    );
  }
}

