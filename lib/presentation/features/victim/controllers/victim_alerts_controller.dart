import 'package:cuutrobaolu/data/repositories/alerts/alert_repository.dart';
import 'package:get/get.dart';

class VictimAlertsController extends GetxController {
  final AlertRepository _alertRepo = AlertRepository();

  final selectedTab = 0.obs; // 0: Active, 1: History
  final activeAlerts = <Map<String, dynamic>>[].obs;
  final historyAlerts = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      // Load active alerts
      _alertRepo.getActiveAlerts().listen((alerts) {
        activeAlerts.value = alerts.map((alert) => _formatAlert(alert)).toList();
      });

      // Load all alerts for history (including expired)
      _alertRepo.getAllAlerts().listen((alerts) {
        final now = DateTime.now();
        final active = <Map<String, dynamic>>[];
        final history = <Map<String, dynamic>>[];

        for (var alert in alerts) {
          final expiresAt = alert['ExpiresAt'] as DateTime?;
          final isActive = alert['IsActive'] == true &&
              (expiresAt == null || expiresAt.isAfter(now));

          final formatted = _formatAlert(alert);
          if (isActive) {
            active.add(formatted);
          } else {
            history.add(formatted);
          }
        }

        activeAlerts.value = active;
        historyAlerts.value = history;
      });
    } catch (e) {
      print('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _formatAlert(Map<String, dynamic> alert) {
    final createdAt = alert['CreatedAt'] as DateTime?;
    final timeAgo = createdAt != null
        ? _getTimeAgo(createdAt)
        : '';

    final location = alert['Location'] as Map<String, dynamic>?;
    final lat = (location?['lat'] ?? alert['Lat']) as num?;
    final lng = (location?['lng'] ?? alert['Lng']) as num?;

    return {
      'id': alert['id'],
      'title': alert['Title'] ?? alert['title'] ?? '',
      'description': alert['Description'] ?? alert['description'] ?? '',
      'severity': alert['Severity'] ?? alert['severity'] ?? 'medium',
      'time': timeAgo,
      'location': lat != null && lng != null
          ? {'lat': lat.toDouble(), 'lng': lng.toDouble()}
          : null,
      'createdAt': createdAt,
    };
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

  void searchAlerts(String query) {
    // Search is handled in the UI by filtering the lists
  }
}
