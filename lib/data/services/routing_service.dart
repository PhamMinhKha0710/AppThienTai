import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Service để tính khoảng cách routing (theo đường đi thực tế)
/// Sử dụng OSRM (Open Source Routing Machine) - miễn phí, không cần API key
class RoutingService extends GetxService {
  static RoutingService get instance => Get.find();
  
  // OSRM public server URL
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';
  
  /// Tính khoảng cách routing giữa 2 điểm (theo đường đi ngắn nhất)
  /// Trả về khoảng cách tính bằng km
  Future<double?> getRouteDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    print('[ROUTING] Calculating route distance:');
    print('[ROUTING] Start: $startLat, $startLng');
    print('[ROUTING] End: $endLat, $endLng');
    
    try {
      // OSRM API format: /route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=false&alternatives=false&steps=false
      final url = Uri.parse(
        '$_osrmBaseUrl/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=false&alternatives=false&steps=false&geometries=geojson',
      );
      
      print('[ROUTING] Request URL: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[ROUTING] Request timeout');
          throw Exception('Routing request timeout');
        },
      );
      
      print('[ROUTING] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[ROUTING] Response code: ${data['code']}');
        
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          // Lấy khoảng cách từ route đầu tiên (tính bằng mét)
          final distanceInMeters = data['routes'][0]['distance'] as num?;
          if (distanceInMeters != null) {
            final distanceKm = distanceInMeters.toDouble() / 1000.0;
            print('[ROUTING] Route distance: $distanceInMeters m = $distanceKm km');
            // Chuyển đổi sang km
            return distanceKm;
          } else {
            print('[ROUTING] Distance is null in response');
          }
        } else if (data['code'] == 'NoRoute') {
          // Không tìm thấy đường đi, fallback về khoảng cách đường thẳng
          print('[ROUTING] No route found, using straight-line distance');
          final straightDistance = Geolocator.distanceBetween(
            startLat,
            startLng,
            endLat,
            endLng,
          ) / 1000.0;
          print('[ROUTING] Straight-line distance: $straightDistance km');
          return straightDistance;
        } else {
          print('[ROUTING] Unexpected response code: ${data['code']}');
          print('[ROUTING] Response body: ${response.body}');
        }
      } else {
        print('[ROUTING] HTTP error: ${response.statusCode}');
        print('[ROUTING] Response body: ${response.body}');
      }
      
      // Nếu API lỗi, fallback về khoảng cách đường thẳng
      print('[ROUTING] OSRM API error, using straight-line distance');
      final straightDistance = Geolocator.distanceBetween(
        startLat,
        startLng,
        endLat,
        endLng,
      ) / 1000.0;
      print('[ROUTING] Straight-line distance: $straightDistance km');
      return straightDistance;
    } catch (e, stackTrace) {
      print('[ROUTING] Error calculating route distance: $e');
      print('[ROUTING] Stack trace: $stackTrace');
      // Fallback về khoảng cách đường thẳng nếu có lỗi
      try {
        final straightDistance = Geolocator.distanceBetween(
          startLat,
          startLng,
          endLat,
          endLng,
        ) / 1000.0;
        print('[ROUTING] Fallback straight-line distance: $straightDistance km');
        return straightDistance;
      } catch (_) {
        print('[ROUTING] Cannot calculate even straight-line distance');
        return null;
      }
    }
  }
  
  /// Tính khoảng cách routing với format đẹp
  Future<String> getFormattedRouteDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final distance = await getRouteDistance(startLat, startLng, endLat, endLng);
    if (distance == null) {
      return 'Không xác định';
    }
    
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} km';
    } else {
      return '${distance.round()} km';
    }
  }
  
  /// Tính khoảng cách routing cho nhiều điểm (batch)
  /// Trả về Map với key là taskId và value là khoảng cách (km)
  Future<Map<String, double>> getBatchRouteDistances(
    double startLat,
    double startLng,
    List<Map<String, dynamic>> tasks,
  ) async {
    final distances = <String, double>{};
    
    // Tính khoảng cách cho từng task (có thể tối ưu bằng batch API nếu cần)
    for (final task in tasks) {
      final taskId = task['id'] as String?;
      final lat = task['lat'] as double?;
      final lng = task['lng'] as double?;
      
      if (taskId != null && lat != null && lng != null) {
        try {
          final distance = await getRouteDistance(startLat, startLng, lat, lng);
          if (distance != null) {
            distances[taskId] = distance;
          }
        } catch (e) {
          print('Error calculating distance for task $taskId: $e');
        }
      }
    }
    
    return distances;
  }
}

