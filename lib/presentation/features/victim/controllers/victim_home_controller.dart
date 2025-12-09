import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class VictimHomeController extends GetxController {
  LocationService? _locationService;
  
  final currentPosition = Rxn<Position>();
  final recentAlerts = <Map<String, dynamic>>[].obs;
  final forecast = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    loadData();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      // Fallback: tạo mới nếu chưa có
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> loadData() async {
    await getCurrentLocation();
    loadAlerts();
    loadForecast();
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }
    final position = await _locationService?.getCurrentLocation();
    currentPosition.value = position;
  }

  void loadAlerts() {
    // TODO: Load from Firestore
    recentAlerts.value = [
      {
        'title': 'Cảnh báo lũ quét',
        'description': 'Khu vực bạn có nguy cơ lũ quét trong 2 giờ tới',
        'severity': 'high',
        'time': '10 phút trước',
      },
      {
        'title': 'Mưa lớn',
        'description': 'Dự báo mưa lớn kéo dài đến tối nay',
        'severity': 'medium',
        'time': '1 giờ trước',
      },
    ];
  }

  void loadForecast() {
    // TODO: Load from ML prediction
    forecast.value = 'Dự đoán ngập trong 12h: Cao';
  }

  Future<void> refreshData() async {
    await loadData();
  }
}

