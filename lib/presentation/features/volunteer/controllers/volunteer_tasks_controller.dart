import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/NavigationVolunteerController.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_map_controller.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart' as di;
import 'package:latlong2/latlong.dart';

class VolunteerTasksController extends GetxController {
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocationService? _locationService;
  RoutingService? _routingService;

  final filterType = 'all'.obs;
  final distanceKm = 10.0.obs;
  final searchQuery = ''.obs;

  final tabs = const ['pending', 'accepted', 'completed'];
  final selectedTab = 0.obs;

  final tasks = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initServices();
    loadTasks();
    
    // Listen to tab changes
    ever(selectedTab, (_) => loadTasks());
  }
  
  void _initServices() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
    
    try {
      _routingService = di.getIt<RoutingService>();
    } catch (_) {
      _routingService = Get.put(RoutingService(), permanent: true);
    }
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final tabKey = tabs[selectedTab.value];
      List<dynamic> requests;

      if (tabKey == 'pending') {
        requests = await _helpRequestRepo
            .getRequestsByStatus(RequestStatus.pending.toJson())
            .first;
      } else if (tabKey == 'accepted') {
        // Get requests accepted by current volunteer (filter by VolunteerId)
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          tasks.value = [];
          isLoading.value = false;
          return;
        }
        // Query directly from Firestore with VolunteerId filter
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('help_requests')
              .where('Status', isEqualTo: 'inProgress')
              .where('VolunteerId', isEqualTo: userId)
              .get();
          
          // Convert Firestore docs to HelpRequest objects
          requests = snapshot.docs.map((doc) {
            return HelpRequest.fromSnapshot(doc);
          }).toList();
        } catch (e) {
          print('Error loading accepted tasks: $e');
          // Fallback: get all inProgress (may not have VolunteerId filter)
          final allInProgress = await _helpRequestRepo
              .getRequestsByStatus(RequestStatus.inProgress.toJson())
              .first;
          requests = allInProgress;
        }
      } else {
        // completed - Get requests completed by current volunteer
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          tasks.value = [];
          isLoading.value = false;
          return;
        }
        // Query directly from Firestore with VolunteerId filter
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('help_requests')
              .where('Status', isEqualTo: 'completed')
              .where('VolunteerId', isEqualTo: userId)
              .get();
          
          // Convert Firestore docs to HelpRequest objects
          requests = snapshot.docs.map((doc) {
            return HelpRequest.fromSnapshot(doc);
          }).toList();
        } catch (e) {
          print('Error loading completed tasks: $e');
          // Fallback: get all completed (may not have VolunteerId filter)
          final allCompleted = await _helpRequestRepo
              .getRequestsByStatus(RequestStatus.completed.toJson())
              .first;
          requests = allCompleted;
        }
      }

      // Get current location for distance calculation
      Position? currentPos;
      try {
        // Ensure location service is initialized
        if (_locationService == null) {
          _initServices();
        }
        
        // Request location permission if needed
        final hasPermission = await _locationService?.checkLocationPermission() ?? false;
        if (!hasPermission) {
          print('Location permission not granted');
        }
        
        // Get current location with timeout
        currentPos = await _locationService?.getCurrentLocation().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Location request timeout');
            return null;
          },
        );
        
        if (currentPos != null) {
          print('Current location: ${currentPos.latitude}, ${currentPos.longitude}');
        } else {
          print('Failed to get current location');
        }
      } catch (e) {
        print('Error getting current location: $e');
      }

      // Convert to map format first (without distance)
      final tasksList = requests.map((req) {
        final severityStr = req.severity.toJson();
        final typeStr = req.type.toJson();
        
        return {
          'id': req.id,
          'status': tabKey,
          'title': req.title,
          'desc': req.description,
          'severity': severityStr,
          'type': typeStr,
          'lat': req.lat,
          'lng': req.lng,
          'address': req.address,
          'createdAt': req.createdAt,
          'distance': 0.0,
          'distanceText': 'Đang tính...',
        };
      }).toList();
      
      // Update tasks immediately (with "Đang tính..." text)
      tasks.value = tasksList;
      
      // Calculate routing distances in parallel (background)
      if (currentPos != null && _routingService != null) {
        print('Starting distance calculation with current position: ${currentPos.latitude}, ${currentPos.longitude}');
        _calculateDistancesInBackground(currentPos, tasksList);
      } else {
        // No location, update all to "Chưa có vị trí"
        print('Cannot calculate distances: currentPos=${currentPos != null}, routingService=${_routingService != null}');
        for (var task in tasksList) {
          if (currentPos == null) {
            task['distanceText'] = 'Chưa có vị trí';
          } else {
            task['distanceText'] = 'Không thể tính';
          }
        }
        tasks.value = tasksList;
      }
    } catch (e) {
      print('Error loading tasks: $e');
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Không thể tải nhiệm vụ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredTasks {
    var filtered = List<Map<String, dynamic>>.from(tasks);

    // Filter by type/severity
    if (filterType.value != 'all') {
      filtered = filtered.where((t) {
        final severity = (t['severity'] ?? '').toString().toLowerCase();
        return severity == filterType.value.toLowerCase();
      }).toList();
    }

    // Filter by distance (using routing distance)
    if (distanceKm.value > 0) {
      filtered = filtered.where((t) {
        final distance = (t['distance'] as num?)?.toDouble() ?? 0.0;
        return distance <= distanceKm.value;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) {
        final title = (t['title'] ?? '').toString().toLowerCase();
        final desc = (t['desc'] ?? '').toString().toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    // Sort by distance (closest first)
    filtered.sort((a, b) {
      final distA = (a['distance'] as num?)?.toDouble() ?? double.infinity;
      final distB = (b['distance'] as num?)?.toDouble() ?? double.infinity;
      return distA.compareTo(distB);
    });

    return filtered;
  }

  Future<void> onAccept(Map<String, dynamic> task) async {
    try {
      final taskId = task['id'] as String;
      final userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Người dùng chưa đăng nhập',
        );
        return;
      }

      await _helpRequestRepo.updateRequestStatus(
        taskId,
        RequestStatus.inProgress,
        volunteerId: userId,
      );

      // Update local state
      task['status'] = 'accepted';
      tasks.refresh();

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã nhận nhiệm vụ thành công!',
      );

      // Reload tasks
      await loadTasks();
    } catch (e) {
      print('Error accepting task: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể nhận nhiệm vụ: $e',
      );
    }
  }

  Future<void> onComplete(Map<String, dynamic> task) async {
    try {
      final taskId = task['id'] as String;
      await _helpRequestRepo.updateRequestStatus(
        taskId,
        RequestStatus.completed,
      );

      // Update local state
      task['status'] = 'completed';
      tasks.refresh();

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã hoàn thành nhiệm vụ!',
      );

      // Reload tasks
      await loadTasks();
    } catch (e) {
      print('Error completing task: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể hoàn thành nhiệm vụ: $e',
      );
    }
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
    loadTasks();
  }
  
  /// Calculate routing distances in background (parallel processing)
  Future<void> _calculateDistancesInBackground(
    Position currentPos,
    List<Map<String, dynamic>> tasksList,
  ) async {
    if (_routingService == null) {
      print('RoutingService is null, cannot calculate distances');
      for (var task in tasksList) {
        task['distanceText'] = 'Không thể tính';
      }
      tasks.value = tasksList;
      return;
    }
    
    print('Calculating routing distances for ${tasksList.length} tasks from position: ${currentPos.latitude}, ${currentPos.longitude}');
    
    // Calculate distances in parallel for better performance
    final futures = tasksList.map((task) async {
      final taskId = task['id'] as String;
      final lat = task['lat'] as double?;
      final lng = task['lng'] as double?;
      
      if (lat == null || lng == null) {
        print('Task $taskId has invalid coordinates');
        task['distanceText'] = 'Không có vị trí';
        return task;
      }
      
      print('Calculating distance to task $taskId at: $lat, $lng');
      
      try {
        final routeDistance = await _routingService!.getRouteDistance(
          currentPos.latitude,
          currentPos.longitude,
          lat,
          lng,
        );
        
        String distanceText;
        if (routeDistance != null) {
          print('Task $taskId distance: $routeDistance km');
          if (routeDistance < 1) {
            distanceText = '${(routeDistance * 1000).round()} m';
          } else if (routeDistance < 10) {
            distanceText = '${routeDistance.toStringAsFixed(1)} km';
          } else {
            distanceText = '${routeDistance.round()} km';
          }
          
          // Update task with distance
          task['distance'] = routeDistance;
          task['distanceText'] = distanceText;
        } else {
          print('Task $taskId: route distance is null');
          task['distanceText'] = 'Không xác định';
        }
      } catch (e) {
        print('Error calculating route distance for task $taskId: $e');
        task['distanceText'] = 'Lỗi tính toán';
      }
      
      return task;
    }).toList();
    
    // Wait for all calculations to complete
    await Future.wait(futures);
    
    print('All distance calculations completed');
    
    // Update tasks list with calculated distances
    tasks.value = tasksList;
  }

  /// Navigate to map screen and focus on task location
  void viewTaskOnMap(Map<String, dynamic> task) {
    final lat = task['lat'] as double?;
    final lng = task['lng'] as double?;
    
    if (lat == null || lng == null) {
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không có thông tin vị trí cho nhiệm vụ này',
      );
      return;
    }

    // Switch to Map tab (index 2 in volunteer navigation)
    NavigationVolunteerController.selectedIndex.value = 2;
    
    // Wait a bit for map screen to load, then focus on location
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        final mapController = Get.find<VolunteerMapController>();
        mapController.focusOnLocation(LatLng(lat, lng));
      } catch (e) {
        print('Error focusing map: $e');
        // If controller not found, just show snackbar
        Get.snackbar(
          'Thông báo',
          'Đã chuyển đến bản đồ. Vị trí: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
          duration: const Duration(seconds: 2),
        );
      }
    });
  }
}
