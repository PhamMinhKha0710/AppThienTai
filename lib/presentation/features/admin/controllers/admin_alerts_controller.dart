import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminAlertsController extends GetxController {
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final selectedTab = 0.obs; // 0: Active, 1: All
  final activeAlerts = <AlertEntity>[].obs;
  final allAlerts = <AlertEntity>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Filters
  final selectedType = Rxn<AlertType>();
  final selectedSeverity = Rxn<AlertSeverity>();
  final selectedAudience = Rxn<TargetAudience>();

  // Form fields for create/edit
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final locationController = TextEditingController();
  final radiusController = TextEditingController();
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final safetyGuideController = TextEditingController();
  
  final selectedFormType = Rx<AlertType>(AlertType.general);
  final selectedFormSeverity = Rx<AlertSeverity>(AlertSeverity.medium);
  final selectedFormAudience = Rx<TargetAudience>(TargetAudience.all);
  final selectedLat = Rxn<double>();
  final selectedLng = Rxn<double>();
  final expiresAt = Rxn<DateTime>();
  final selectedImages = <XFile>[].obs;
  final uploadedImageUrls = <String>[].obs;
  final isUploading = false.obs;

  // Editing alert
  final editingAlert = Rxn<AlertEntity>();

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    locationController.dispose();
    radiusController.dispose();
    provinceController.dispose();
    districtController.dispose();
    safetyGuideController.dispose();
    super.onClose();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      // Load active alerts
      _alertRepo.getActiveAlerts().listen((alerts) {
        activeAlerts.value = alerts;
      });

      // Load all alerts
      _alertRepo.getAllAlerts().listen((alerts) {
        allAlerts.value = alerts;
      });
    } catch (e) {
      print('Error loading alerts: $e');
      Get.snackbar('Lỗi', 'Không thể tải danh sách cảnh báo');
    } finally {
      isLoading.value = false;
    }
  }

  List<AlertEntity> get currentList {
    final source = selectedTab.value == 0 ? activeAlerts : allAlerts;
    var filtered = source.where((alert) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!alert.title.toLowerCase().contains(query) &&
            !alert.content.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Type filter
      if (selectedType.value != null && alert.alertType != selectedType.value) {
        return false;
      }

      // Severity filter
      if (selectedSeverity.value != null && alert.severity != selectedSeverity.value) {
        return false;
      }

      // Audience filter
      if (selectedAudience.value != null && alert.targetAudience != selectedAudience.value) {
        return false;
      }

      return true;
    }).toList();

    // Sort by severity (critical first) then by created date
    filtered.sort((a, b) {
      final severityCompare = _severityToInt(b.severity).compareTo(_severityToInt(a.severity));
      if (severityCompare != 0) return severityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
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

  void search(String query) {
    searchQuery.value = query;
  }

  void filterByType(AlertType? type) {
    selectedType.value = type;
  }

  void filterBySeverity(AlertSeverity? severity) {
    selectedSeverity.value = severity;
  }

  void filterByAudience(TargetAudience? audience) {
    selectedAudience.value = audience;
  }

  void clearFilters() {
    selectedType.value = null;
    selectedSeverity.value = null;
    selectedAudience.value = null;
    searchQuery.value = '';
  }

  // CRUD Operations
  Future<void> createAlert() async {
    if (!_validateForm()) return;

    isUploading.value = true;
    try {
      // Upload images first
      await _uploadImages();

      final alert = AlertEntity(
        id: '', // Will be set by Firestore
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        severity: selectedFormSeverity.value,
        alertType: selectedFormType.value,
        targetAudience: selectedFormAudience.value,
        lat: selectedLat.value,
        lng: selectedLng.value,
        location: locationController.text.trim().isEmpty 
            ? null 
            : locationController.text.trim(),
        radiusKm: radiusController.text.trim().isEmpty 
            ? null 
            : double.tryParse(radiusController.text.trim()),
        province: provinceController.text.trim().isEmpty 
            ? null 
            : provinceController.text.trim(),
        district: districtController.text.trim().isEmpty 
            ? null 
            : districtController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        expiresAt: expiresAt.value,
        safetyGuide: safetyGuideController.text.trim().isEmpty 
            ? null 
            : safetyGuideController.text.trim(),
        imageUrls: uploadedImageUrls.isEmpty ? null : uploadedImageUrls.toList(),
      );

      await _alertRepo.createAlert(alert);
      Get.back();
      Get.snackbar('Thành công', 'Đã tạo cảnh báo thành công');
      _clearForm();
      await loadAlerts();
    } catch (e) {
      print('Error creating alert: $e');
      Get.snackbar('Lỗi', 'Không thể tạo cảnh báo: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updateAlert() async {
    if (editingAlert.value == null || !_validateForm()) return;

    isUploading.value = true;
    try {
      // Upload new images if any
      await _uploadImages();

      // Merge old and new image URLs
      final allImageUrls = <String>[
        ...(editingAlert.value!.imageUrls ?? []),
        ...uploadedImageUrls,
      ];

      final alert = editingAlert.value!.copyWith(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        severity: selectedFormSeverity.value,
        alertType: selectedFormType.value,
        targetAudience: selectedFormAudience.value,
        lat: selectedLat.value,
        lng: selectedLng.value,
        location: locationController.text.trim().isEmpty 
            ? null 
            : locationController.text.trim(),
        radiusKm: radiusController.text.trim().isEmpty 
            ? null 
            : double.tryParse(radiusController.text.trim()),
        province: provinceController.text.trim().isEmpty 
            ? null 
            : provinceController.text.trim(),
        district: districtController.text.trim().isEmpty 
            ? null 
            : districtController.text.trim(),
        updatedAt: DateTime.now(),
        expiresAt: expiresAt.value,
        safetyGuide: safetyGuideController.text.trim().isEmpty 
            ? null 
            : safetyGuideController.text.trim(),
        imageUrls: allImageUrls.isEmpty ? null : allImageUrls,
      );

      await _alertRepo.updateAlert(alert);
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật cảnh báo thành công');
      _clearForm();
      await loadAlerts();
    } catch (e) {
      print('Error updating alert: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật cảnh báo: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa cảnh báo này?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _alertRepo.deleteAlert(alertId);
        Get.snackbar('Thành công', 'Đã xóa cảnh báo thành công');
        await loadAlerts();
      }
    } catch (e) {
      print('Error deleting alert: $e');
      Get.snackbar('Lỗi', 'Không thể xóa cảnh báo: $e');
    }
  }

  Future<void> deactivateAlert(String alertId) async {
    try {
      await _alertRepo.deactivateAlert(alertId);
      Get.snackbar('Thành công', 'Đã vô hiệu hóa cảnh báo');
      await loadAlerts();
    } catch (e) {
      print('Error deactivating alert: $e');
      Get.snackbar('Lỗi', 'Không thể vô hiệu hóa cảnh báo: $e');
    }
  }

  void startEdit(AlertEntity alert) {
    editingAlert.value = alert;
    titleController.text = alert.title;
    contentController.text = alert.content;
    selectedFormType.value = alert.alertType;
    selectedFormSeverity.value = alert.severity;
    selectedFormAudience.value = alert.targetAudience;
    selectedLat.value = alert.lat;
    selectedLng.value = alert.lng;
    locationController.text = alert.location ?? '';
    radiusController.text = alert.radiusKm?.toString() ?? '';
    provinceController.text = alert.province ?? '';
    districtController.text = alert.district ?? '';
    expiresAt.value = alert.expiresAt;
    safetyGuideController.text = alert.safetyGuide ?? '';
    uploadedImageUrls.value = alert.imageUrls ?? [];
    selectedImages.clear();
  }

  // Image handling
  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images);
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Lỗi', 'Không thể chọn ảnh');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> _uploadImages() async {
    if (selectedImages.isEmpty) return;

    uploadedImageUrls.clear();
    for (var image in selectedImages) {
      try {
        final file = File(image.path);
        final fileName = 'alerts/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = _storage.ref().child(fileName);
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        uploadedImageUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề');
      return false;
    }

    if (contentController.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập nội dung');
      return false;
    }

    if (selectedFormAudience.value == TargetAudience.locationBased) {
      if (selectedLat.value == null || selectedLng.value == null) {
        Get.snackbar('Lỗi', 'Vui lòng chọn vị trí trên bản đồ cho cảnh báo theo vị trí');
        return false;
      }

      if (radiusController.text.trim().isEmpty) {
        Get.snackbar('Lỗi', 'Vui lòng nhập bán kính cho cảnh báo theo vị trí');
        return false;
      }
    }

    return true;
  }

  void _clearForm() {
    titleController.clear();
    contentController.clear();
    locationController.clear();
    radiusController.clear();
    provinceController.clear();
    districtController.clear();
    safetyGuideController.clear();
    selectedFormType.value = AlertType.general;
    selectedFormSeverity.value = AlertSeverity.medium;
    selectedFormAudience.value = TargetAudience.all;
    selectedLat.value = null;
    selectedLng.value = null;
    expiresAt.value = null;
    selectedImages.clear();
    uploadedImageUrls.clear();
    editingAlert.value = null;
  }
}


