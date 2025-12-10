import 'package:cuutrobaolu/data/repositories/alerts/alert_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VolunteerAlertsController extends GetxController {
  final AlertRepository _alertRepo = AlertRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final selectedTab = 0.obs; // 0: tất cả, 1: liên quan nhiệm vụ
  final query = ''.obs;
  final isLoading = false.obs;

  final allAlerts = <Map<String, dynamic>>[].obs;
  final taskAlerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      // Load all alerts
      _alertRepo.getAllAlerts().listen((alerts) {
        allAlerts.value = alerts.map((alert) => _formatAlert(alert)).toList();
      });

      // Load task-related alerts
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        _alertRepo.getTaskRelatedAlerts(userId).listen((alerts) {
          taskAlerts.value = alerts.map((alert) => _formatAlert(alert)).toList();
        });
      }
    } catch (e) {
      print('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _formatAlert(Map<String, dynamic> alert) {
    final createdAt = alert['CreatedAt'] as DateTime?;
    final timeStr = createdAt != null
        ? DateFormat('HH:mm dd/MM').format(createdAt)
        : '';

    return {
      'id': alert['id'],
      'title': alert['Title'] ?? alert['title'] ?? '',
      'description': alert['Description'] ?? alert['description'] ?? '',
      'severity': alert['Severity'] ?? alert['severity'] ?? 'medium',
      'time': timeStr,
      'createdAt': createdAt,
    };
  }

  List<Map<String, dynamic>> get currentList {
    final source = selectedTab.value == 0 ? allAlerts : taskAlerts;
    if (query.value.isEmpty) return source;
    return source
        .where((a) =>
            (a['title'] ?? '').toLowerCase().contains(query.value.toLowerCase()) ||
            (a['description'] ?? '').toLowerCase().contains(query.value.toLowerCase()))
        .toList();
  }

  void search(String text) {
    query.value = text;
  }
}
