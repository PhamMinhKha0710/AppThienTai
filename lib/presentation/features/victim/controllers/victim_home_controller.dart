import 'dart:async';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class VictimHomeController extends GetxController {
  LocationService? _locationService;
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  
  final currentPosition = Rxn<Position>();
  final recentAlerts = <Map<String, dynamic>>[].obs;
  final myRequests = <HelpRequestEntity>[].obs;
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
          final createdAt = alert.createdAt;
          final timeAgo = _getTimeAgo(createdAt);

          return {
            'id': alert.id,
            'title': alert.title,
            'description': alert.content,
            'severity': alert.severity,
            'time': timeAgo,
            'createdAt': createdAt,
          };
        }).toList();
      } else {
        // Fallback: load active alerts
        _alertRepo.getActiveAlerts().listen((alerts) {
          recentAlerts.value = alerts.take(5).map((alert) {
            final createdAt = alert.createdAt;
            final timeAgo = _getTimeAgo(createdAt);

            return {
              'id': alert.id,
              'title': alert.title,
              'description': alert.content,
              'severity': alert.severity,
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
