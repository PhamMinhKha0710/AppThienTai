import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:get/get.dart';

class VictimAlertsController extends GetxController {
  final AlertRepository _alertRepo = getIt<AlertRepository>();

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
      // Load all alerts
      _alertRepo.getAllAlerts().listen((alerts) {
        final now = DateTime.now();
        final active = <Map<String, dynamic>>[];
        final history = <Map<String, dynamic>>[];

        for (var alert in alerts) {
          final expiresAt = alert.expiresAt;
          final isActive = alert.isActive &&
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

  Map<String, dynamic> _formatAlert(AlertEntity alert) {
    final createdAt = alert.createdAt;
    final timeAgo = _getTimeAgo(createdAt);

    return {
      'id': alert.id,
      'title': alert.title,
      'description': alert.content,
      'severity': alert.severity, // severity is already a String
      'time': timeAgo,
      'location': alert.lat != null && alert.lng != null
          ? {'lat': alert.lat!, 'lng': alert.lng!}
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
