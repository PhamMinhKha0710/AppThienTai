import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cuutrobaolu/domain/usecases/create_help_request_usecase.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/presentation/utils/help_request_mapper.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/service/CloudinaryService.dart';
import 'package:cuutrobaolu/core/utils/network_manager.dart';

class SosQueueService extends GetxService {
  static const String _storageKey = 'sos_queue';
  final GetStorage _storage = GetStorage();
  final _processing = false.obs;
  Timer? _timer;

  CreateHelpRequestUseCase get _createUseCase => Get.find<CreateHelpRequestUseCase>();

  List<Map<String, dynamic>> get _queue {
    final raw = _storage.read(_storageKey);
    if (raw == null) return [];
    try {
      final list = (raw as List).cast<dynamic>();
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveQueue(List<Map<String, dynamic>> q) async {
    await _storage.write(_storageKey, q);
  }

  Future<void> enqueue(Map<String, dynamic> sos) async {
    final q = _queue;
    final entry = Map<String, dynamic>.from(sos);
    entry['attempts'] = 0;
    entry['createdAt'] = DateTime.now().toIso8601String();
    q.add(entry);
    await _saveQueue(q);
    // Try processing immediately if online
    if (await NetworkManager.instance.isConnected()) {
      processQueue();
    }
  }

  Future<void> processQueue() async {
    if (_processing.value) return;
    _processing.value = true;
    try {
      if (!await NetworkManager.instance.isConnected()) return;
      var q = _queue;
      if (q.isEmpty) return;
      // iterate copy to allow removal
      for (var item in List<Map<String, dynamic>>.from(q)) {
        try {
          // upload image if present and is local path
          if (item['imagePath'] != null && (item['imageUrl'] == null || item['imageUrl'].isEmpty)) {
            try {
              final uploaded = await CloudinaryService.uploadImageInAsset(item['imagePath']);
              if (uploaded != null) {
                item['imageUrl'] = uploaded;
              }
            } catch (_) {}
          }

          // build HelpRequest model
          final model = HelpRequest(
            id: "",
            title: item['title'] ?? "SOS Khẩn cấp",
            description: item['description'] ?? '',
            lat: (item['lat'] as num).toDouble(),
            lng: (item['lng'] as num).toDouble(),
            contact: item['contact'] ?? '',
            address: item['address'] ?? '',
            imageUrl: item['imageUrl'],
            userId: item['userId'] ?? '',
            severity: item['severity'] ?? RequestSeverity.urgent,
            type: item['type'] ?? RequestType.rescue,
            status: RequestStatus.pending,
          );

          final entity = HelpRequestMapper.toEntity(model);
          await _createUseCase(entity);
          // on success remove from queue
          q.remove(item);
          await _saveQueue(q);
        } catch (e) {
          // increment attempts
          item['attempts'] = (item['attempts'] as int?) != null ? (item['attempts'] as int) + 1 : 1;
          // if too many attempts, keep but skip for now
          if ((item['attempts'] as int) >= 3) {
            // leave in queue but don't retry immediately
          }
          await _saveQueue(q);
        }
      }
    } finally {
      _processing.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getQueue() async {
    return _queue;
  }

  @override
  void onInit() {
    super.onInit();
    // attempt processing periodically when service is alive
    _timer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (await NetworkManager.instance.isConnected()) {
        await processQueue();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}


