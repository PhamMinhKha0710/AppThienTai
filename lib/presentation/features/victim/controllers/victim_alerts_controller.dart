import 'package:get/get.dart';

class VictimAlertsController extends GetxController {
  final selectedTab = 0.obs;
  final activeAlerts = <Map<String, dynamic>>[].obs;
  final historyAlerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  void loadAlerts() {
    // TODO: Load from Firestore
    activeAlerts.value = [
      {
        'title': 'Cảnh báo lũ quét khu vực bạn',
        'description': 'Khu vực bạn có nguy cơ lũ quét trong 2 giờ tới. Vui lòng di chuyển đến nơi an toàn.',
        'severity': 'high',
        'time': '10 phút trước',
        'location': {'lat': 10.762622, 'lng': 106.660172},
      },
      {
        'title': 'Mưa lớn',
        'description': 'Dự báo mưa lớn kéo dài đến tối nay',
        'severity': 'medium',
        'time': '1 giờ trước',
      },
    ];

    historyAlerts.value = [
      {
        'title': 'Cảnh báo bão đã qua',
        'description': 'Bão đã di chuyển ra khỏi khu vực',
        'severity': 'low',
        'time': '2 ngày trước',
      },
    ];
  }

  void searchAlerts(String query) {
    // TODO: Implement search
  }
}


