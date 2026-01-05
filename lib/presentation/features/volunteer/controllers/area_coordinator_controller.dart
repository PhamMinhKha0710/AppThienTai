import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/domain/repositories/area_coordinator_repository.dart';
import 'package:cuutrobaolu/domain/entities/area_coordinator_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AreaCoordinatorController extends GetxController {
  final AreaCoordinatorRepository _coordinatorRepo =
      getIt<AreaCoordinatorRepository>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final coordinatorStatus = Rxn<AreaCoordinatorEntity>();
  final isLoading = false.obs;
  final isCoordinator = false.obs;

  // Form fields
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCoordinatorStatus();
  }

  @override
  void onClose() {
    provinceController.dispose();
    districtController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> loadCoordinatorStatus() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        coordinatorStatus.value = await _coordinatorRepo.getCoordinatorByUser(userId);
        isCoordinator.value = coordinatorStatus.value?.isApproved ?? false;
      }
    } catch (e) {
      print('Error loading coordinator status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyAsCoordinator() async {
    if (provinceController.text.trim().isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng nhập tỉnh/thành phố",
      );
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("Người dùng chưa đăng nhập");
      }

      await _coordinatorRepo.applyAsCoordinator(
        userId: userId,
        province: provinceController.text.trim(),
        district: districtController.text.trim().isEmpty
            ? null
            : districtController.text.trim(),
      );

      await loadCoordinatorStatus();

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Đơn đăng ký đã được gửi. Vui lòng chờ admin duyệt.",
      );

      // Clear form
      provinceController.clear();
      districtController.clear();
      reasonController.clear();
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể đăng ký: $e",
      );
    }
  }

  Future<bool> checkIfCoordinator(String province, String? district) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      return await _coordinatorRepo.isCoordinatorOfArea(
        userId,
        province,
        district,
      );
    } catch (e) {
      print('Error checking coordinator: $e');
      return false;
    }
  }
}

