import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VolunteerAlertsController extends GetxController {
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final selectedTab = 0.obs; // 0: all, 1: task-related
  final query = ''.obs;
  final isLoading = false.obs;

  final allAlerts = <AlertEntity>[].obs;
  final taskAlerts = <AlertEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      // Load all active alerts relevant to volunteers
      _alertRepo.getActiveAlerts().listen((alerts) {
        // Filter alerts relevant to volunteers
        final relevantAlerts = alerts.where((alert) {
          return alert.targetAudience == TargetAudience.all ||
                 alert.targetAudience == TargetAudience.volunteers;
        }).toList();

        // Sort by severity and created date
        relevantAlerts.sort(_compareAlerts);
        
        allAlerts.value = relevantAlerts;
      });

      // Load task-related alerts for this volunteer
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        _alertRepo.getTaskRelatedAlerts(userId).listen((alerts) {
          // Sort by severity and created date
          alerts.sort(_compareAlerts);
          taskAlerts.value = alerts;
        });
      }
    } catch (e) {
      print('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  int _compareAlerts(AlertEntity a, AlertEntity b) {
    // Sort by severity (critical first)
    final severityCompare = _severityToInt(b.severity)
        .compareTo(_severityToInt(a.severity));
    if (severityCompare != 0) return severityCompare;

    // Then by created date (newest first)
    return b.createdAt.compareTo(a.createdAt);
  }

  int _severityToInt(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 4;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.low:
        return 1;
    }
  }

  List<AlertEntity> get currentList {
    final source = selectedTab.value == 0 ? allAlerts : taskAlerts;
    
    if (query.value.isEmpty) return source;
    
    return source.where((alert) {
      final searchQuery = query.value.toLowerCase();
      return alert.title.toLowerCase().contains(searchQuery) ||
             alert.content.toLowerCase().contains(searchQuery);
    }).toList();
  }

  void search(String text) {
    query.value = text;
  }

  void navigateToDetail(AlertEntity alert) {
    Get.to(() => AlertDetailScreen(alert: alert));
  }
}
