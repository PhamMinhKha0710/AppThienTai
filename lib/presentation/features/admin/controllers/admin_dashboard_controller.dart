import 'dart:async';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/presentation/features/admin/NavigationAdminController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Realtime stats
  final pendingSOS = 0.obs;
  final inProgressSOS = 0.obs;
  final completedSOS = 0.obs;
  final activeVolunteers = 0.obs;
  
  // Recent SOS requests
  final recentSOS = <Map<String, dynamic>>[].obs;
  
  // Shelter status
  final shelterStats = <Map<String, dynamic>>[].obs;
  
  // SOS type distribution
  final sosTypeDistribution = <Map<String, dynamic>>[].obs;
  
  // Weekly stats (last 7 days)
  final weeklyStats = <Map<String, dynamic>>[].obs;

  // Map data (pending SOS markers)
  final mapSOS = <Map<String, dynamic>>[].obs;
  
  final isLoading = false.obs;
  
  StreamSubscription? _pendingSub;
  StreamSubscription? _inProgressSub;
  StreamSubscription? _completedSub;
  StreamSubscription? _allRequestsSub;
  StreamSubscription? _sheltersSub;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _setupRealtimeListeners();
  }
  
  @override
  void onClose() {
    _pendingSub?.cancel();
    _inProgressSub?.cancel();
    _completedSub?.cancel();
    _allRequestsSub?.cancel();
    _sheltersSub?.cancel();
    super.onClose();
  }
  
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadRecentSOS(),
        loadShelterStats(),
        loadSOSTypeDistribution(),
        loadWeeklyStats(),
        loadMapSOS(),
      ]);
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _setupRealtimeListeners() {
    try {
      // Listen to pending SOS count
      _pendingSub = _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.pending)
          .listen(
            (requests) {
              pendingSOS.value = requests.length;
            },
            onError: (error) {
              print('[ADMIN_DASHBOARD] Error listening to pending SOS: $error');
            },
          );
      
      // Listen to inProgress SOS count
      _inProgressSub = _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.inProgress)
          .listen(
            (requests) {
              inProgressSOS.value = requests.length;
            },
            onError: (error) {
              print('[ADMIN_DASHBOARD] Error listening to inProgress SOS: $error');
            },
          );
      
      // Listen to completed SOS count
      _completedSub = _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.completed)
          .listen(
            (requests) {
              completedSOS.value = requests.length;
            },
            onError: (error) {
              print('[ADMIN_DASHBOARD] Error listening to completed SOS: $error');
            },
          );
      
      // Count active volunteers (Users with UserType = volunteer and online in last 30 mins)
      _firestore.collection('Users')
          .where('UserType', isEqualTo: 'volunteer')
          .snapshots()
          .listen(
            (snapshot) {
              try {
                // Count users who were active in last 30 minutes
                final now = DateTime.now();
                final activeCount = snapshot.docs.where((doc) {
                  final data = doc.data();
                  final lastActive = data['LastActive'] as Timestamp?;
                  if (lastActive != null) {
                    final diff = now.difference(lastActive.toDate());
                    return diff.inMinutes <= 30;
                  }
                  return false;
                }).length;
                
                activeVolunteers.value = activeCount;
              } catch (e) {
                print('[ADMIN_DASHBOARD] Error processing active volunteers: $e');
              }
            },
            onError: (error) {
              print('[ADMIN_DASHBOARD] Error listening to active volunteers: $error');
            },
          );

      // Real-time listener for recent SOS and map SOS
      _allRequestsSub = _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.pending)
          .listen(
            (requests) {
              // Update recent SOS (take 5 most recent)
              final recent = requests.take(5).map((req) {
                return {
                  'id': req.id,
                  'title': req.title,
                  'severity': req.severity.viName,
                  'address': req.address,
                  'createdAt': req.createdAt,
                  'lat': req.lat,
                  'lng': req.lng,
                };
              }).toList();
              recentSOS.value = recent;

              // Update map SOS
              mapSOS.value = requests
                  .map((req) => {
                        'id': req.id,
                        'title': req.title,
                        'lat': req.lat,
                        'lng': req.lng,
                        'severity': req.severity.viName,
                      })
                  .toList();
            },
            onError: (error) {
              print('[ADMIN_DASHBOARD] Error listening to all requests: $error');
            },
          );

      // Real-time listener for SOS type distribution (today)
      _helpRequestRepo.getAllRequests().listen(
        (allRequests) {
          try {
            final today = DateTime.now();
            final start = DateTime(today.year, today.month, today.day);
            final end = start.add(const Duration(days: 1));
            final todaySOS = allRequests.where((req) {
              final created = req.createdAt;
              return created.isAfter(start) && created.isBefore(end);
            }).toList();

            // Count by type
            final Map<String, int> distribution = {};
            for (var request in todaySOS) {
              final type = request.type.viName;
              distribution[type] = (distribution[type] ?? 0) + 1;
            }

            // Convert to list of maps
            final result = distribution.entries.map((entry) {
              return {
                'type': entry.key,
                'count': entry.value,
              };
            }).toList();

            // Sort by count descending
            result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

            sosTypeDistribution.value = result;
          } catch (e) {
            print('[ADMIN_DASHBOARD] Error processing SOS type distribution: $e');
          }
        },
        onError: (error) {
          print('[ADMIN_DASHBOARD] Error listening to SOS type distribution: $error');
        },
      );

      // Real-time listener for shelter stats
      _sheltersSub = _shelterRepo.getAllShelters().listen(
        (shelters) {
          try {
            final stats = <Map<String, dynamic>>[];
            for (var shelter in shelters) {
              final capacity = shelter.capacity;
              final occupancy = shelter.currentOccupancy;
              final available = capacity - occupancy;
              final percent = capacity > 0 ? (occupancy / capacity * 100).toInt() : 0;

              // Only show shelters that are nearly full (> 80%)
              if (percent > 80) {
                stats.add({
                  'id': shelter.id,
                  'name': shelter.name,
                  'capacity': capacity,
                  'occupancy': occupancy,
                  'available': available,
                  'percent': percent,
                });
              }
            }

            shelterStats.value = stats;
          } catch (e) {
            print('[ADMIN_DASHBOARD] Error processing shelter stats: $e');
            shelterStats.value = [];
          }
        },
        onError: (error) {
          print('[ADMIN_DASHBOARD] Error listening to shelters: $error');
        },
      );
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error setting up realtime listeners: $e');
    }
  }
  
  Future<void> loadRecentSOS() async {
    try {
      final allSOS = await _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.pending)
          .first
          .timeout(const Duration(seconds: 10));
      
      // Take 5 most recent
      final recent = allSOS.take(5).map((req) {
        return {
          'id': req.id,
          'title': req.title,
          'severity': req.severity.viName,
          'address': req.address,
          'createdAt': req.createdAt,
          'lat': req.lat,
          'lng': req.lng,
        };
      }).toList();
      
      recentSOS.value = recent;
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error loading recent SOS: $e');
      recentSOS.value = []; // Set empty list on error
    }
  }
  
  Future<void> loadShelterStats() async {
    try {
      final shelters = await _shelterRepo.getAllShelters().first
          .timeout(const Duration(seconds: 10));
      
      final stats = <Map<String, dynamic>>[];
      for (var shelter in shelters) {
        final capacity = shelter.capacity;
        final occupancy = shelter.currentOccupancy;
        final available = capacity - occupancy;
        final percent = capacity > 0 ? (occupancy / capacity * 100).toInt() : 0;
        
        // Only show shelters that are nearly full (> 80%)
        if (percent > 80) {
          stats.add({
            'id': shelter.id,
            'name': shelter.name,
            'capacity': capacity,
            'occupancy': occupancy,
            'available': available,
            'percent': percent,
          });
        }
      }
      
      shelterStats.value = stats;
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error loading shelter stats: $e');
      shelterStats.value = []; // Set empty list on error
    }
  }
  
  Future<void> loadMapSOS() async {
    try {
      final pending = await _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.pending)
          .first
          .timeout(const Duration(seconds: 10));

      mapSOS.value = pending
          .map((req) => {
                'id': req.id,
                'title': req.title,
                'lat': req.lat,
                'lng': req.lng,
                'severity': req.severity.viName,
              })
          .toList();
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error loading map SOS: $e');
      mapSOS.value = []; // Set empty list on error
    }
  }

  Future<void> loadSOSTypeDistribution() async {
    try {
      final allSOS = await _helpRequestRepo.getAllRequests().first
          .timeout(const Duration(seconds: 10));
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));
      final todaySOS = allSOS.where((req) {
        final created = req.createdAt;
        return created.isAfter(start) && created.isBefore(end);
      }).toList();
      
      // Count by type
      final Map<String, int> distribution = {};
      for (var request in todaySOS) {
        final type = request.type.viName;
        distribution[type] = (distribution[type] ?? 0) + 1;
      }
      
      // Convert to list of maps
      final result = distribution.entries.map((entry) {
        return {
          'type': entry.key,
          'count': entry.value,
        };
      }).toList();
      
      // Sort by count descending
      result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      
      sosTypeDistribution.value = result;
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error loading SOS type distribution: $e');
      sosTypeDistribution.value = []; // Set empty list on error
    }
  }
  
  Future<void> loadWeeklyStats() async {
    try {
      final now = DateTime.now();
      final stats = <Map<String, dynamic>>[];
      
      // Get data for last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        // Count completed requests for this day
        final snapshot = await _firestore
            .collection('help_requests')
            .where('Status', isEqualTo: 'completed')
            .where('UpdatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('UpdatedAt', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
        
        stats.add({
          'day': _getDayName(date.weekday),
          'count': snapshot.docs.length,
          'date': date,
        });
      }
      
      weeklyStats.value = stats;
    } catch (e) {
      print('[ADMIN_DASHBOARD] Error loading weekly stats: $e');
      // Fallback: show mock data
      weeklyStats.value = [
        {'day': 'T2', 'count': 5},
        {'day': 'T3', 'count': 8},
        {'day': 'T4', 'count': 12},
        {'day': 'T5', 'count': 7},
        {'day': 'T6', 'count': 10},
        {'day': 'T7', 'count': 6},
        {'day': 'CN', 'count': 4},
      ];
    }
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'T2';
      case 2: return 'T3';
      case 3: return 'T4';
      case 4: return 'T5';
      case 5: return 'T6';
      case 6: return 'T7';
      case 7: return 'CN';
      default: return '';
    }
  }
  
  Future<void> refreshData() async {
    await loadDashboardData();
  }
  
  void navigateToSOS() {
    // Navigate to SOS management screen (index 1)
    NavigationAdminController.selectedIndex.value = 1;
  }
  
  void navigateToAlerts() {
    // Navigate to Alerts management screen (index 2)
    NavigationAdminController.selectedIndex.value = 2;
  }

  void showCreateAlertDialog() {
    // Navigate to alerts screen instead of showing dialog
    navigateToAlerts();
  }
  
  void showCreateTaskDialog() {
    // Navigate to SOS screen where admin can create tasks
    navigateToSOS();
    Get.snackbar(
      'Tạo nhiệm vụ',
      'Chuyển đến màn hình quản lý SOS để tạo nhiệm vụ mới',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  void showAddShelterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Thêm điểm trú ẩn'),
        content: const Text('Tính năng quản lý điểm trú ẩn đang được phát triển. Sẽ có sẵn trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

