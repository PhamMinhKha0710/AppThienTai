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

  // Filter and sort options
  final selectedSeverityFilter = Rxn<AlertSeverity>();
  final selectedTypeFilter = Rxn<AlertType>();
  final sortOption = 'severity'.obs; // 'severity', 'date'

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
    var source = (selectedTab.value == 0 ? allAlerts : taskAlerts).toList();

    // Apply search filter
    if (query.value.isNotEmpty) {
      final searchQuery = query.value.toLowerCase();
      source = source.where((alert) {
        return alert.title.toLowerCase().contains(searchQuery) ||
               alert.content.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply severity filter
    if (selectedSeverityFilter.value != null) {
      source = source.where((alert) {
        return alert.severity == selectedSeverityFilter.value;
      }).toList();
    }

    // Apply type filter
    if (selectedTypeFilter.value != null) {
      source = source.where((alert) {
        return alert.alertType == selectedTypeFilter.value;
      }).toList();
    }

    // Apply sort
    source = _applySort(source);

    return source;
  }

  List<AlertEntity> _applySort(List<AlertEntity> alerts) {
    final sort = sortOption.value;
    final sorted = List<AlertEntity>.from(alerts);

    switch (sort) {
      case 'severity':
        sorted.sort(_compareAlerts);
        break;
      case 'date':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        sorted.sort(_compareAlerts);
    }

    return sorted;
  }

  void filterBySeverity(AlertSeverity? severity) {
    selectedSeverityFilter.value = severity;
  }

  void filterByType(AlertType? type) {
    selectedTypeFilter.value = type;
  }

  void setSortOption(String option) {
    if (['severity', 'date'].contains(option)) {
      sortOption.value = option;
    }
  }

  void clearFilters() {
    selectedSeverityFilter.value = null;
    selectedTypeFilter.value = null;
    sortOption.value = 'severity';
  }

  void search(String text) {
    query.value = text;
  }

  void navigateToDetail(AlertEntity alert) {
    Get.to(() => AlertDetailScreen(alert: alert));
  }
}
