import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/NavigationVolunteerController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class VolunteerHomeController extends GetxController {
  LocationService? _locationService;
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final stats = {
    'tasksCompleted': 0,
    'badge': 'Hero L1',
  }.obs;

  final nearbyTasks = <Map<String, dynamic>>[].obs;
  final currentPosition = Rxn<Position>();

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

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await getCurrentLocation();
      await loadStats();
      await loadNearbyTasks();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> loadStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Count completed tasks
      final completedRequests = await _helpRequestRepo
          .getRequestsByStatus(RequestStatus.completed.toJson())
          .first;

      final userCompleted = completedRequests
          .where((req) => req.userId == userId)
          .length;

      stats.value = {
        'tasksCompleted': userCompleted,
        'badge': _getBadgeLevel(userCompleted),
      };
    } catch (e) {
      print('Error loading stats: $e');
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
      print('[VOLUNTEER_HOME] Loading nearby rescue requests from database...');
      
      if (currentPosition.value == null) {
        print('[VOLUNTEER_HOME] Getting current location...');
        await getCurrentLocation();
      }

      final position = currentPosition.value;
      if (position == null) {
        print('[VOLUNTEER_HOME] No position available');
        return;
      }
      
      print('[VOLUNTEER_HOME] Current position: ${position.latitude}, ${position.longitude}');

      // Get pending rescue requests from real database (help_requests collection)
      print('[VOLUNTEER_HOME] Fetching pending rescue requests from Firestore...');
      final allRequests = await _helpRequestRepo
          .getRequestsByStatus(RequestStatus.pending.toJson())
          .first;
      
      print('[VOLUNTEER_HOME] Found ${allRequests.length} pending rescue requests in database');

      // Calculate distance and filter nearby (within 50km radius)
      final nearby = <Map<String, dynamic>>[];
      for (var request in allRequests) {
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          request.lat,
          request.lng,
        );
        
        print('[VOLUNTEER_HOME] Request "${request.title}" - Distance: ${distance.toStringAsFixed(1)} km');

        if (distance <= 50) {
          nearby.add({
            'id': request.id,
            'title': request.title,
            'distance': '${distance.toStringAsFixed(1)} km',
            'severity': request.severity.viName,
            'type': request.type.viName,
            'description': request.description,
            'address': request.address,
            'lat': request.lat,
            'lng': request.lng,
            'createdAt': request.createdAt,
            'userId': request.userId, // User who created the request
          });
        }
      }
      
      print('[VOLUNTEER_HOME] Found ${nearby.length} rescue points within 50km');

      // Sort by distance (closest first) and take top 5
      nearby.sort((a, b) {
        final distA = double.parse(a['distance'].toString().replaceAll(' km', ''));
        final distB = double.parse(b['distance'].toString().replaceAll(' km', ''));
        return distA.compareTo(distB);
      });

      nearbyTasks.value = nearby.take(5).toList();
      print('[VOLUNTEER_HOME] Displaying top ${nearbyTasks.length} nearest rescue points');
    } catch (e) {
      print('[VOLUNTEER_HOME] Error loading nearby rescue requests: $e');
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000; // km
  }

  Future<void> refreshData() async {
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
      
      // Update task status to inProgress
      await _helpRequestRepo.updateRequestStatus(
        taskId,
        RequestStatus.inProgress,
        volunteerId: userId,
      );
      
      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã nhận nhiệm vụ thành công!',
      );
      
      // Refresh data and navigate to tasks tab
      await loadData();
      NavigationVolunteerController.selectedIndex.value = 1; // Navigate to Tasks tab
    } catch (e) {
      print('Error accepting task: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể nhận nhiệm vụ: $e',
      );
    }
  }
}
