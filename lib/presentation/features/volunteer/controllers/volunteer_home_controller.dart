import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/NavigationVolunteerController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class VolunteerHomeController extends GetxController {
  LocationService? _locationService;
  // Use getIt for consistent dependency injection
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final stats = {
    'tasksCompleted': 0,
    'badge': 'Hero L1',
  }.obs;

  final nearbyTasks = <Map<String, dynamic>>[].obs;
  final currentPosition = Rxn<Position>();

  // Location cache
  Position? _cachedPosition;
  DateTime? _positionCacheTime;
  static const _locationCacheDuration = Duration(seconds: 60);

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    loadData();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  /// Load all data in parallel for faster loading
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Get location first (needed for nearby tasks)
      await getCurrentLocation();

      // Load stats and nearby tasks in parallel
      await Future.wait([
        loadStats(),
        loadNearbyTasks(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current location with caching
  Future<void> getCurrentLocation() async {
    try {
      // Check cache first
      final now = DateTime.now();
      if (_cachedPosition != null &&
          _positionCacheTime != null &&
          now.difference(_positionCacheTime!) < _locationCacheDuration) {
        currentPosition.value = _cachedPosition;
        return;
      }

      final position = await _locationService?.getCurrentLocation();
      if (position != null) {
        _cachedPosition = position;
        _positionCacheTime = now;
        currentPosition.value = position;
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> loadStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Count completed tasks using domain repository
      final completedRequests = await _helpRequestRepo
          .getRequestsByStatus(RequestStatus.completed)
          .first;

      final userCompleted = completedRequests
          .where((req) => req.userId == userId)
          .length;

      stats.value = {
        'tasksCompleted': userCompleted,
        'badge': _getBadgeLevel(userCompleted),
      };
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  String _getBadgeLevel(int completed) {
    if (completed >= 50) return 'Hero L5';
    if (completed >= 30) return 'Hero L4';
    if (completed >= 20) return 'Hero L3';
    if (completed >= 10) return 'Hero L2';
    return 'Hero L1';
  }

  Future<void> loadNearbyTasks() async {
    try {
      debugPrint('[VOLUNTEER_HOME] Loading nearby rescue requests from database...');

      final position = currentPosition.value;
      if (position == null) {
        debugPrint('[VOLUNTEER_HOME] No position available');
        return;
      }

      debugPrint('[VOLUNTEER_HOME] Current position: ${position.latitude}, ${position.longitude}');

      // Get pending rescue requests from real database (help_requests collection)
      final allRequests = await _helpRequestRepo
          .getRequestsByStatus(RequestStatus.pending)
          .first;

      debugPrint('[VOLUNTEER_HOME] Found ${allRequests.length} pending rescue requests in database');

      // Calculate distance and filter nearby (within 50km radius)
      final nearby = <Map<String, dynamic>>[];
      for (var request in allRequests) {
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          request.lat,
          request.lng,
        );

        if (distance <= 50) {
          nearby.add({
            'id': request.id,
            'title': request.title,
            'distance': '${distance.toStringAsFixed(1)} km',
            'distanceValue': distance, // Store numeric value for sorting
            'severity': request.severity.viName,
            'type': request.type.viName,
            'description': request.description,
            'address': request.address,
            'lat': request.lat,
            'lng': request.lng,
            'createdAt': request.createdAt,
            'userId': request.userId,
          });
        }
      }

      debugPrint('[VOLUNTEER_HOME] Found ${nearby.length} rescue points within 50km');

      // Sort by distance (closest first) and take top 5
      nearby.sort((a, b) {
        final distA = a['distanceValue'] as double;
        final distB = b['distanceValue'] as double;
        return distA.compareTo(distB);
      });

      nearbyTasks.value = nearby.take(5).toList();
      debugPrint('[VOLUNTEER_HOME] Displaying top ${nearbyTasks.length} nearest rescue points');
    } catch (e) {
      debugPrint('[VOLUNTEER_HOME] Error loading nearby rescue requests: $e');
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000; // km
  }

  Future<void> refreshData() async {
    // Clear cache to force fresh data
    _cachedPosition = null;
    _positionCacheTime = null;
    await loadData();
  }

  /// Accept a task from nearby tasks list
  Future<void> acceptTask(Map<String, dynamic> task) async {
    try {
      final taskId = task['id'] as String?;
      final userId = _auth.currentUser?.uid;

      if (taskId == null || userId == null) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Không thể nhận nhiệm vụ',
        );
        return;
      }

      // Update task status to inProgress using domain repository
      await _helpRequestRepo.updateRequestStatus(
        taskId,
        RequestStatus.inProgress,
      );

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã nhận nhiệm vụ thành công!',
      );

      // Refresh data and navigate to tasks tab
      await loadData();
      NavigationVolunteerController.selectedIndex.value = 1; // Navigate to Tasks tab
    } catch (e) {
      debugPrint('Error accepting task: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể nhận nhiệm vụ: $e',
      );
    }
  }
}
