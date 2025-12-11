import 'dart:async';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/repositories/alerts/alert_repository.dart';
import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class VictimHomeController extends GetxController {
  LocationService? _locationService;
  final AlertRepository _alertRepo = AlertRepository();
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();
  
  final currentPosition = Rxn<Position>();
  final recentAlerts = <Map<String, dynamic>>[].obs;
  final myRequests = <HelpRequest>[].obs;
  final forecast = Rxn<String>();
  final isLoading = false.obs;
  
  StreamSubscription? _myRequestsSub;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    loadData();
    _setupMyRequestsListener();
  }
  
  @override
  void onClose() {
    _myRequestsSub?.cancel();
    super.onClose();
  }
  
  void _setupMyRequestsListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    _myRequestsSub = _helpRequestRepo
        .getRequestsByUserId(user.uid)
        .listen((requests) {
      myRequests.value = requests;
    });
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await getCurrentLocation();
      await loadAlerts();
      loadForecast();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
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

  Future<void> loadAlerts() async {
    try {
      if (currentPosition.value == null) {
        await getCurrentLocation();
      }

      final position = currentPosition.value;
      if (position != null) {
        // Load nearby alerts (within 20km)
        final nearby = await _alertRepo.getNearbyAlerts(
          position.latitude,
          position.longitude,
          20.0,
        );

        recentAlerts.value = nearby.take(5).map((alert) {
          final createdAt = alert['CreatedAt'] as DateTime?;
          final timeAgo = createdAt != null
              ? _getTimeAgo(createdAt)
              : '';

          return {
            'id': alert['id'],
            'title': alert['Title'] ?? alert['title'] ?? '',
            'description': alert['Description'] ?? alert['description'] ?? '',
            'severity': alert['Severity'] ?? alert['severity'] ?? 'medium',
            'time': timeAgo,
            'createdAt': createdAt,
          };
        }).toList();
      } else {
        // Fallback: load active alerts
        _alertRepo.getActiveAlerts().listen((alerts) {
          recentAlerts.value = alerts.take(5).map((alert) {
            final createdAt = alert['CreatedAt'] as DateTime?;
            final timeAgo = createdAt != null
                ? _getTimeAgo(createdAt)
                : '';

            return {
              'id': alert['id'],
              'title': alert['Title'] ?? alert['title'] ?? '',
              'description': alert['Description'] ?? alert['description'] ?? '',
              'severity': alert['Severity'] ?? alert['severity'] ?? 'medium',
              'time': timeAgo,
              'createdAt': createdAt,
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading alerts: $e');
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  void loadForecast() {
    // TODO: Load from ML prediction service
    // For now, use mock
    forecast.value = 'Dự đoán ngập trong 12h: Cao';
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
