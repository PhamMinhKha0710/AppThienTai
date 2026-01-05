import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service quản lý chế độ Offline và đồng bộ dữ liệu
class OfflineService extends GetxService {
  static OfflineService get to => Get.find();
  
  // Hive Boxes
  late Box<String> _sosQueueBox;
  late Box<dynamic> _offlineGuidesBox;
  late Box<dynamic> _emergencyContactsBox;
  
  // Observables
  final isOnline = true.obs;
  final pendingSosCount = 0.obs;
  final isSyncing = false.obs;

  StreamSubscription? _connectivitySubscription;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initHiveBoxes();
    _initConnectivityListener();
    _checkPendingItems();
  }
  
  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
  
  Future<void> _initHiveBoxes() async {
    _sosQueueBox = await Hive.openBox<String>('sos_queue');
    _offlineGuidesBox = await Hive.openBox('offline_guides');
    _emergencyContactsBox = await Hive.openBox('emergency_contacts');
  }
  
  void _initConnectivityListener() {
    // Initial check
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
    
    // Listen to changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Nếu danh sách chứa none -> offline, ngược lại check xem có mobile/wifi không
    final hasNet = !results.contains(ConnectivityResult.none);
    isOnline.value = hasNet;
    
    if (hasNet) {
      debugPrint('[OFFLINE_SERVICE] Online! Attempting sync...');
      syncData();
    } else {
      debugPrint('[OFFLINE_SERVICE] Offline mode activated');
    }
  }
  
  void _checkPendingItems() {
    pendingSosCount.value = _sosQueueBox.length;
  }
  
  // --- SOS Queue Methods ---
  
  Future<void> cacheSosRequest(Map<String, dynamic> data) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      // Add timestamp
      data['cachedAt'] = DateTime.now().toIso8601String();
      
      await _sosQueueBox.put(id, jsonEncode(data));
      _checkPendingItems();
      
      Get.snackbar(
        'Đã lưu Offline',
        'Mất kết nối mạng. Yêu cầu cứu trợ đã được lưu và sẽ tự động gửi khi có mạng.',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('[OFFLINE_SERVICE] Error caching SOS: $e');
    }
  }
  
  List<Map<String, dynamic>> getPendingSosRequests() {
    return _sosQueueBox.values.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Returns a map of Key -> Data so we can delete specific items by key
  Map<dynamic, Map<String, dynamic>> getPendingSosRequestsWithKey() {
    final Map<dynamic, Map<String, dynamic>> result = {};
    for (var key in _sosQueueBox.keys) {
      try {
        final value = _sosQueueBox.get(key);
        if (value != null) {
          result[key] = jsonDecode(value) as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('Error decoding SOS item $key: $e');
      }
    }
    return result;
  }
  
  Future<void> updateSosRequest(String key, Map<String, dynamic> data) async {
    await _sosQueueBox.put(key, jsonEncode(data));
    _checkPendingItems();
  }

  Future<void> removeSosRequest(String key) async {
    await _sosQueueBox.delete(key);
    _checkPendingItems();
  }

  Future<void> clearSosQueue() async {
    await _sosQueueBox.clear();
    _checkPendingItems();
  }
  
  // --- Sync Logic ---
  
  Future<void> syncData() async {
    if (isSyncing.value || _sosQueueBox.isEmpty) return;
    
    isSyncing.value = true;
    int successCount = 0;
    
    try {
      // Lazy load SosQueueService to avoid circular dependency issues if any
      // But better implementation is to use a callback or dependency injection
      // For now, we assume external service handles the actual API call logic
      // We expose a stream or callback, OR we trigger the sync processed elsewhere.
      
      // OPTION: Notify SosQueueService to process
      // But since SosQueueService uses GetStorage and this uses Hive, 
      // we are transitioning. For Phase 7, we will fully migrate SosQueueService
      // to use THIS service as the backing storage.
      
      // Placeholder for actual sync logic which will be called by SosQueueService
      
    } finally {
      isSyncing.value = false;
    }
  }
  
  // --- Data Seeding (Emergency Contacts) ---
  Future<void> seedDefaultData() async {
    if (_emergencyContactsBox.isEmpty) {
      await _emergencyContactsBox.putAll({
        'police': {'name': 'Cảnh sát 113', 'number': '113'},
        'fire': {'name': 'Cứu hỏa 114', 'number': '114'},
        'ambulance': {'name': 'Cấp cứu 115', 'number': '115'},
      });
    }
  }
}
