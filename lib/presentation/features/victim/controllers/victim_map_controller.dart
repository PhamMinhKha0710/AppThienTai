import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';
import 'package:cuutrobaolu/data/repositories/shelters/shelter_repository.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart' as di;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VictimMapController extends GetxController {
  LocationService? _locationService;
  RoutingService? _routingService;
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();
  final ShelterRepository _shelterRepo = ShelterRepository();
  
  final currentPosition = Rxn<Position>();
  final disasterMarkers = <Marker>[].obs;
  final shelterMarkers = <Marker>[].obs;
  final selectedShelter = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final routePolylines = <Polyline>[].obs;

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
    
    try {
      _routingService = di.getIt<RoutingService>();
    } catch (e) {
      _routingService = Get.put(RoutingService(), permanent: true);
    }
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }
    try {
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> loadDisasterMarkers() async {
    isLoading.value = true;
    try {
      // Load high severity requests as disaster markers
      final highSeverityRequests = await _helpRequestRepo
          .getRequestsBySeverity(RequestSeverity.high.toJson())
          .first;

      disasterMarkers.value = highSeverityRequests.map((req) {
        return Marker(
          point: LatLng(req.lat, req.lng),
          width: 40,
          height: 40,
          child: Icon(Icons.warning, color: Colors.red, size: 40),
        );
      }).toList();
    } catch (e) {
      print('Error loading disaster markers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadShelterMarkers() async {
    try {
      final shelters = await _shelterRepo.getAllShelters().first;

      shelterMarkers.value = shelters.map((shelter) {
        final lat = (shelter['Lat'] as num?)?.toDouble() ?? 0.0;
        final lng = (shelter['Lng'] as num?)?.toDouble() ?? 0.0;
        final name = shelter['Name'] ?? shelter['name'] ?? 'Điểm trú ẩn';
        final address = shelter['Address'] ?? shelter['address'] ?? '';
        final capacity = (shelter['Capacity'] ?? shelter['capacity'] ?? 0) as num;
        final occupancy = (shelter['CurrentOccupancy'] ?? shelter['currentOccupancy'] ?? 0) as num;
        final available = capacity.toInt() - occupancy.toInt();

        return Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              final shelterData = {
                'id': shelter['id'],
                'name': name,
                'address': address,
                'available': available,
                'capacity': capacity.toInt(),
                'occupancy': occupancy.toInt(),
                'lat': lat,
                'lng': lng,
              };
              selectedShelter.value = shelterData;
              _showShelterInfo(shelterData);
            },
            child: Icon(Icons.home, color: Colors.green, size: 40),
          ),
        );
      }).toList();
    } catch (e) {
      print('Error loading shelter markers: $e');
    }
  }

  Future<void> searchShelter(String query) async {
    try {
      final allShelters = await _shelterRepo.getAllShelters().first;
      final queryLower = query.toLowerCase();

      final filtered = allShelters.where((shelter) {
        final name = (shelter['Name'] ?? shelter['name'] ?? '').toString().toLowerCase();
        final address = (shelter['Address'] ?? shelter['address'] ?? '').toString().toLowerCase();
        return name.contains(queryLower) || address.contains(queryLower);
      }).toList();

      // Update markers with filtered results
      shelterMarkers.value = filtered.map((shelter) {
        final lat = (shelter['Lat'] as num?)?.toDouble() ?? 0.0;
        final lng = (shelter['Lng'] as num?)?.toDouble() ?? 0.0;
        return Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: Icon(Icons.home, color: Colors.green, size: 40),
        );
      }).toList();
    } catch (e) {
      print('Error searching shelters: $e');
    }
  }

  void filterDisasterType(String type) {
    // Reload markers with filter
    loadDisasterMarkers();
  }

  Future<void> findRoute() async {
    if (currentPosition.value == null || selectedShelter.value == null) {
      Get.snackbar('Lỗi', 'Không thể tìm đường: Thiếu thông tin vị trí');
      return;
    }
    
    try {
      isLoading.value = true;
      
      final start = LatLng(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
      );
      final end = LatLng(
        selectedShelter.value!['lat'],
        selectedShelter.value!['lng'],
      );
      
      print('[VICTIM_MAP] Finding route from $start to $end');
      
      // Get route using OSRM
      if (_routingService != null) {
        final routePoints = await _getRoutePoints(start, end);
        
        if (routePoints != null && routePoints.isNotEmpty) {
          routePolylines.value = [
            Polyline(
              points: routePoints,
              strokeWidth: 4,
              color: Colors.blue,
            ),
          ];
          
          final distance = await _routingService!.getFormattedRouteDistance(
            start.latitude,
            start.longitude,
            end.latitude,
            end.longitude,
          );
          
          Get.snackbar(
            'Đã tìm thấy đường đi',
            'Khoảng cách: $distance',
            duration: const Duration(seconds: 3),
          );
        } else {
          // Fallback: straight line
          routePolylines.value = [
            Polyline(
              points: [start, end],
              strokeWidth: 3,
              color: Colors.blue.withOpacity(0.5),
            ),
          ];
          Get.snackbar('Thông báo', 'Không tìm thấy đường đi, hiển thị đường thẳng');
        }
      } else {
        // No routing service, show straight line
        routePolylines.value = [
          Polyline(
            points: [start, end],
            strokeWidth: 3,
            color: Colors.blue.withOpacity(0.5),
          ),
        ];
      }
    } catch (e) {
      print('[VICTIM_MAP] Error finding route: $e');
      Get.snackbar('Lỗi', 'Không thể tìm đường: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<List<LatLng>?> _getRoutePoints(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );
      
      print('[VICTIM_MAP] Fetching route geometry from OSRM...');
      
      final geoResponse = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Route request timeout'),
      );
      
      if (geoResponse.statusCode == 200) {
        final data = json.decode(geoResponse.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          if (geometry != null && geometry['coordinates'] != null) {
            final coordinates = geometry['coordinates'] as List;
            final points = coordinates.map((coord) {
              return LatLng(coord[1] as double, coord[0] as double);
            }).toList();
            print('[VICTIM_MAP] Got ${points.length} route points');
            return points;
          }
        }
      }
      print('[VICTIM_MAP] Failed to get route geometry');
    } catch (e) {
      print('[VICTIM_MAP] Error getting route points: $e');
    }
    return null;
  }

  void showReportDialog(LatLng point) {
    Get.dialog(
      AlertDialog(
        title: const Text('Báo cáo thiên tai'),
        content: Text(
          'Bạn muốn gửi yêu cầu SOS tại vị trí:\n'
          'Vĩ độ: ${point.latitude.toStringAsFixed(6)}\n'
          'Kinh độ: ${point.longitude.toStringAsFixed(6)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to SOS screen
              Get.toNamed('/sos', arguments: {
                'lat': point.latitude,
                'lng': point.longitude,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi SOS'),
          ),
        ],
      ),
    );
  }
  
  void _showShelterInfo(Map<String, dynamic> shelter) {
    final available = shelter['available'] as int;
    final capacity = shelter['capacity'] as int;
    final occupancy = shelter['occupancy'] as int;
    final availabilityPercent = capacity > 0 ? (available / capacity * 100).toInt() : 0;
    
    Color statusColor = Colors.green;
    String statusText = 'Còn chỗ';
    if (availabilityPercent < 20) {
      statusColor = Colors.red;
      statusText = 'Gần đầy';
    } else if (availabilityPercent < 50) {
      statusColor = Colors.orange;
      statusText = 'Còn ít chỗ';
    }
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shelter['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (shelter['address'] != null && shelter['address'].toString().isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shelter['address'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                  icon: Icons.people,
                  label: 'Sức chứa',
                  value: '$capacity',
                ),
                _InfoChip(
                  icon: Icons.person,
                  label: 'Đang ở',
                  value: '$occupancy',
                ),
                _InfoChip(
                  icon: Icons.check_circle,
                  label: 'Còn trống',
                  value: '$available',
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: findRoute,
                icon: const Icon(Icons.directions),
                label: const Text('Chỉ đường đến đây'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  void refreshMarkers() {
    loadDisasterMarkers();
    loadShelterMarkers();
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color ?? Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
