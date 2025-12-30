import 'dart:async';

import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/NavigationVolunteerController.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_map_controller.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:latlong2/latlong.dart';

class VolunteerTasksController extends GetxController {
  // Use getIt for consistent dependency injection
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocationService? _locationService;
  RoutingService? _routingService;

  final filterType = 'all'.obs;
  // Default to a wide radius so volunteers can see more tasks
  final distanceKm = 150.0.obs;
  final searchQuery = ''.obs;

  final tabs = const ['pending', 'accepted', 'completed'];
  final selectedTab = 0.obs;

  final tasks = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  StreamSubscription<List<HelpRequest>>? _taskSub;

  // Location cache - avoid fetching location on every stream emit
  Position? _cachedPosition;
  DateTime? _positionCacheTime;
  static const _locationCacheDuration = Duration(seconds: 60);

  // Distance calculation cache
  final Map<String, double> _distanceCache = {};

  @override
  void onInit() {
    super.onInit();
    _initServices();
    
    // Pre-fetch location once at init
    _prefetchLocation();

    listenTasksRealtime();

    ever(selectedTab, (_) => listenTasksRealtime());
  }

  @override
  void onClose() {
    _taskSub?.cancel();
    _distanceCache.clear();
    super.onClose();
  }

<<<<<<< Updated upstream
  /// Pre-fetch location at initialization to avoid delay later
  Future<void> _prefetchLocation() async {
    try {
      _cachedPosition = await _locationService?.getCurrentLocation();
      _positionCacheTime = DateTime.now();
    } catch (e) {
      debugPrint('Error prefetching location: $e');
    }
  }

  /// Get cached position or fetch new one if cache expired
  Future<Position?> _getCachedPosition() async {
    final now = DateTime.now();
    
    // Return cached position if still valid
    if (_cachedPosition != null &&
        _positionCacheTime != null &&
        now.difference(_positionCacheTime!) < _locationCacheDuration) {
      return _cachedPosition;
    }

    // Cache expired or not available, fetch new position
    try {
      _cachedPosition = await _locationService?.getCurrentLocation();
      _positionCacheTime = DateTime.now();
      _distanceCache.clear(); // Clear distance cache when position changes
      return _cachedPosition;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return _cachedPosition; // Return stale cache if fetch fails
    }
  }

=======
>>>>>>> Stashed changes
  void listenTasksRealtime() {
    _taskSub?.cancel(); // huỷ stream cũ khi đổi tab
    isLoading.value = true;

    final tabKey = tabs[selectedTab.value];
    final userId = _auth.currentUser?.uid;

    Stream<List<HelpRequest>> stream;

    if (tabKey == 'pending') {
      stream = FirebaseFirestore.instance
          .collection('help_requests')
          .where('Status', isEqualTo: 'pending')
          .snapshots()
          .map((s) => s.docs.map((d) => HelpRequest.fromSnapshot(d)).toList());
    } else if (tabKey == 'accepted') {
      if (userId == null) {
        tasks.clear();
        isLoading.value = false;
        return;
      }

      stream = FirebaseFirestore.instance
          .collection('help_requests')
          .where('Status', isEqualTo: 'inProgress')
          .where('VolunteerId', isEqualTo: userId)
          .snapshots()
          .map((s) => s.docs.map((d) => HelpRequest.fromSnapshot(d)).toList());
    } else {
      if (userId == null) {
        tasks.clear();
        isLoading.value = false;
        return;
      }

      stream = FirebaseFirestore.instance
          .collection('help_requests')
          .where('Status', isEqualTo: 'completed')
          .where('VolunteerId', isEqualTo: userId)
          .snapshots()
          .map((s) => s.docs.map((d) => HelpRequest.fromSnapshot(d)).toList());
    }

    _taskSub = stream.listen(
      (requests) async {
        await _handleIncomingTasks(requests);
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        debugPrint('Realtime error: $e');
      },
    );
  }

  Future<void> _handleIncomingTasks(List<HelpRequest> requests) async {
    // 1. Convert sang map trước
    final list = requests.map((req) {
      return {
        'id': req.id,
        'status': req.status.toJson(),
        'title': req.title,
        'desc': req.description,
        'severity': req.severity.toJson(),
        'type': req.type.toJson(),
        'lat': req.lat,
        'lng': req.lng,
        'address': req.address,
        'createdAt': req.createdAt,
        'distance': 0.0,
        'distanceText': 'Đang tính...',
      };
    }).toList();

    tasks.value = list; // update UI NGAY

    // 2. Use CACHED location - avoid slow location fetch on every stream emit
    final currentPos = await _getCachedPosition();

    if (currentPos != null && _routingService != null) {
      _calculateDistancesInBackground(currentPos, list);
    } else {
      for (var t in list) {
        t['distanceText'] = 'Chưa có vị trí';
      }
      tasks.value = list;
    }
  }

  void _initServices() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }

    try {
      _routingService = getIt<RoutingService>();
    } catch (_) {
      _routingService = Get.put(RoutingService(), permanent: true);
    }
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final tabKey = tabs[selectedTab.value];
      List<domain.HelpRequestEntity> requests;

      debugPrint("tabKey: $tabKey");
      if (tabKey == 'pending') {
        requests = await _helpRequestRepo
            .getRequestsByStatus(domain.RequestStatus.pending)
            .first;

        debugPrint("requests: $requests");
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

          // Convert Firestore docs to domain entities
          requests = snapshot.docs.map((doc) {
            final helpRequest = HelpRequest.fromSnapshot(doc);
            return domain.HelpRequestEntity(
              id: helpRequest.id,
              title: helpRequest.title,
              description: helpRequest.description,
              address: helpRequest.address,
              contact: helpRequest.contact,
              lat: helpRequest.lat,
              lng: helpRequest.lng,
              status: _mapStatus(helpRequest.status),
              severity: _mapSeverity(helpRequest.severity),
              type: _mapType(helpRequest.type),
              userId: helpRequest.userId,
              createdAt: helpRequest.createdAt,
              updatedAt: helpRequest.updatedAt,
            );
          }).toList();
        } catch (e) {
          debugPrint('Error loading accepted tasks: $e');
          // Fallback: get all inProgress
          requests = await _helpRequestRepo
              .getRequestsByStatus(domain.RequestStatus.inProgress)
              .first;
        }
      } else {
        // completed - Get requests completed by current volunteer
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          tasks.value = [];
          isLoading.value = false;
          return;
        }
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('help_requests')
              .where('Status', isEqualTo: 'completed')
              .where('VolunteerId', isEqualTo: userId)
              .get();

          requests = snapshot.docs.map((doc) {
            final helpRequest = HelpRequest.fromSnapshot(doc);
            return domain.HelpRequestEntity(
              id: helpRequest.id,
              title: helpRequest.title,
              description: helpRequest.description,
              address: helpRequest.address,
              contact: helpRequest.contact,
              lat: helpRequest.lat,
              lng: helpRequest.lng,
              status: _mapStatus(helpRequest.status),
              severity: _mapSeverity(helpRequest.severity),
              type: _mapType(helpRequest.type),
              userId: helpRequest.userId,
              createdAt: helpRequest.createdAt,
              updatedAt: helpRequest.updatedAt,
            );
          }).toList();
        } catch (e) {
          debugPrint('Error loading completed tasks: $e');
          requests = await _helpRequestRepo
              .getRequestsByStatus(domain.RequestStatus.completed)
              .first;
        }
      }

      // Get current location using CACHE
      final currentPos = await _getCachedPosition();

      if (currentPos != null) {
        debugPrint(
          'Current location: ${currentPos.latitude}, ${currentPos.longitude}',
        );
      } else {
        debugPrint('Failed to get current location');
      }

      // Convert to map format first (without distance)
      final tasksList = requests.map((req) {
        return {
          'id': req.id,
          'status': tabKey,
          'title': req.title,
          'desc': req.description,
          'severity': req.severity.name,
          'type': req.type.name,
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
        debugPrint(
          'Starting distance calculation with current position: ${currentPos.latitude}, ${currentPos.longitude}',
        );
        _calculateDistancesInBackground(currentPos, tasksList);
      } else {
        // No location, update all to "Chưa có vị trí"
        debugPrint(
          'Cannot calculate distances: currentPos=${currentPos != null}, routingService=${_routingService != null}',
        );
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
      debugPrint('Error loading tasks: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể tải nhiệm vụ: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods to map between enum types
  domain.RequestStatus _mapStatus(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return domain.RequestStatus.pending;
      case RequestStatus.inProgress:
        return domain.RequestStatus.inProgress;
      case RequestStatus.completed:
        return domain.RequestStatus.completed;
      case RequestStatus.cancelled:
        return domain.RequestStatus.cancelled;
    }
  }

  domain.RequestSeverity _mapSeverity(RequestSeverity severity) {
    switch (severity) {
      case RequestSeverity.low:
        return domain.RequestSeverity.low;
      case RequestSeverity.medium:
        return domain.RequestSeverity.medium;
      case RequestSeverity.high:
        return domain.RequestSeverity.high;
      case RequestSeverity.urgent:
        return domain.RequestSeverity.urgent;
    }
  }

  domain.RequestType _mapType(RequestType type) {
    switch (type) {
      case RequestType.rescue:
        return domain.RequestType.rescue;
      case RequestType.medicine:
        return domain.RequestType.medicine;
      case RequestType.food:
        return domain.RequestType.food;
      case RequestType.water:
        return domain.RequestType.water;
      case RequestType.shelter:
        return domain.RequestType.shelter;
      case RequestType.clothes:
        return domain.RequestType.clothes;
      case RequestType.other:
        return domain.RequestType.other;
    }
  }

  List<Map<String, dynamic>> get filteredTasks {
    var filtered = List<Map<String, dynamic>>.from(tasks);

<<<<<<< Updated upstream
=======
    // Debug từng task
    for (var i = 0; i < filtered.length; i++) {
      var t = filtered[i];
      print(
        'Task ${i + 1}: id=${t['id']}, severity=${t['severity']}, distance=${t['distance']}',
      );
    }

>>>>>>> Stashed changes
    // Filter by type/severity
    if (filterType.value != 'all') {
      filtered = filtered.where((t) {
        final severity = (t['severity'] ?? '').toString().toLowerCase();
        return severity == filterType.value.toLowerCase();
      }).toList();
    }

    // Filter by distance
    if (distanceKm.value > 0) {
      filtered = filtered.where((t) {
        final distance = (t['distance'] as num?)?.toDouble() ?? 0.0;
        return distance <= distanceKm.value;
      }).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        final title = (t['title'] ?? '').toString().toLowerCase();
        final desc = (t['desc'] ?? '').toString().toLowerCase();
        final query = searchQuery.value.toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

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

      // Update using domain repository
      await _helpRequestRepo.updateRequestStatus(
        taskId,
        domain.RequestStatus.inProgress,
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
      debugPrint('Error accepting task: $e');
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
        domain.RequestStatus.completed,
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
      debugPrint('Error completing task: $e');
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

  /// Calculate routing distances in background with caching
  Future<void> _calculateDistancesInBackground(
    Position currentPos,
    List<Map<String, dynamic>> tasksList,
  ) async {
    if (_routingService == null) {
      debugPrint('RoutingService is null, cannot calculate distances');
      for (var task in tasksList) {
        task['distanceText'] = 'Không thể tính';
      }
      tasks.value = tasksList;
      return;
    }

    debugPrint(
      'Calculating routing distances for ${tasksList.length} tasks from position: ${currentPos.latitude}, ${currentPos.longitude}',
    );

    // Calculate distances in parallel for better performance
    final futures = tasksList.map((task) async {
      final taskId = task['id'] as String;
      final lat = task['lat'] as double?;
      final lng = task['lng'] as double?;

      if (lat == null || lng == null) {
        debugPrint('Task $taskId has invalid coordinates');
        task['distanceText'] = 'Không có vị trí';
        return task;
      }

      // Check cache first
      final cacheKey = taskId;
      if (_distanceCache.containsKey(cacheKey)) {
        final cachedDistance = _distanceCache[cacheKey]!;
        task['distance'] = cachedDistance;
        task['distanceText'] = _formatDistance(cachedDistance);
        return task;
      }

      try {
        final routeDistance = await _routingService!.getRouteDistance(
          currentPos.latitude,
          currentPos.longitude,
          lat,
          lng,
        );

        if (routeDistance != null) {
          // Cache the result
          _distanceCache[cacheKey] = routeDistance;
          task['distance'] = routeDistance;
          task['distanceText'] = _formatDistance(routeDistance);
        } else {
          task['distanceText'] = 'Không xác định';
        }
      } catch (e) {
        debugPrint('Error calculating route distance for task $taskId: $e');
        task['distanceText'] = 'Lỗi tính toán';
      }

      return task;
    }).toList();

    // Wait for all calculations to complete
    await Future.wait(futures);

    debugPrint('All distance calculations completed');

    // Update tasks list with calculated distances
    tasks.value = tasksList;
  }

  /// Format distance for display
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }

  /// Clear caches and refresh location
  Future<void> refreshLocation() async {
    _cachedPosition = null;
    _positionCacheTime = null;
    _distanceCache.clear();
    await _prefetchLocation();
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
        final target = LatLng(lat, lng);
        // Di chuyển camera
        mapController.focusOnLocation(target);
        // Vẽ đường đi từ vị trí hiện tại của tình nguyện viên tới nhiệm vụ
        mapController.findRouteTo(target);
      } catch (e) {
        debugPrint('Error focusing map: $e');
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
