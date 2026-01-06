import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/domain/repositories/donation_plan_repository.dart';
import 'package:cuutrobaolu/domain/entities/donation_plan_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuutrobaolu/core/constants/supply_categories.dart';

class DonationPlanController extends GetxController {
  final DonationPlanRepository _planRepo = getIt<DonationPlanRepository>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final plans = <DonationPlanEntity>[].obs;
  final isLoading = false.obs;
  final selectedPlan = Rxn<DonationPlanEntity>();

  // Form fields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final expiresAt = Rxn<DateTime>();

  // Required items
  final requiredItems = <DonationPlanItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    provinceController.dispose();
    districtController.dispose();
    super.onClose();
  }

  Future<void> loadPlans() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      print('=== LOAD DONATION PLANS ===');
      print('User ID: $userId');
      
      if (userId != null) {
        final loadedPlans = await _planRepo.getPlansByCoordinator(userId);
        print('Loaded ${loadedPlans.length} plans');
        loadedPlans.forEach((p) {
          print('  - Plan: ${p.id} | ${p.title} | Status: ${p.status.name}');
        });
        plans.value = loadedPlans;
      } else {
        print('No user ID - clearing plans');
        plans.value = [];
      }
    } catch (e) {
      print('ERROR loading plans: $e');
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể tải danh sách kế hoạch: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPlan() async {
    print('=== CREATE DONATION PLAN ===');
    
    if (titleController.text.trim().isEmpty ||
        provinceController.text.trim().isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng điền đầy đủ thông tin",
      );
      return;
    }

    if (requiredItems.isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng thêm ít nhất một vật phẩm cần quyên góp",
      );
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("Người dùng chưa đăng nhập");
      }
      
      print('Creating plan for user: $userId');
      print('Title: ${titleController.text.trim()}');
      print('Province: ${provinceController.text.trim()}');
      print('Required items: ${requiredItems.length}');

      final plan = DonationPlanEntity(
        id: '',
        coordinatorId: userId,
        province: provinceController.text.trim(),
        district: districtController.text.trim().isEmpty
            ? null
            : districtController.text.trim(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        requiredItems: requiredItems.toList(),
        status: DonationPlanStatus.active,
        createdAt: DateTime.now(),
        expiresAt: expiresAt.value,
      );

      print('Calling repository createPlan...');
      final createdPlanId = await _planRepo.createPlan(plan);
      print('Plan created with ID: $createdPlanId');
      
      print('Reloading plans...');
      await loadPlans();
      print('Plans reloaded. Total: ${plans.length}');

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Kế hoạch quyên góp đã được tạo",
      );

      // Clear form
      clearForm();
      print('Form cleared');
    } catch (e) {
      print('ERROR creating plan: $e');
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể tạo kế hoạch: $e",
      );
    }
  }

  Future<void> updatePlan(DonationPlanEntity plan) async {
    try {
      await _planRepo.updatePlan(plan);
      await loadPlans();

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Kế hoạch đã được cập nhật",
      );
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể cập nhật kế hoạch: $e",
      );
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _planRepo.deletePlan(planId);
      await loadPlans();

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Kế hoạch đã được xóa",
      );
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể xóa kế hoạch: $e",
      );
    }
  }

  void addRequiredItem({
    SupplyCategory? category,
    String? customCategory,
    required int quantity,
    String? description,
  }) {
    requiredItems.add(DonationPlanItem(
      category: category,
      customCategory: customCategory,
      quantity: quantity,
      description: description,
    ));
  }

  void removeRequiredItem(int index) {
    if (index >= 0 && index < requiredItems.length) {
      requiredItems.removeAt(index);
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    provinceController.clear();
    districtController.clear();
    requiredItems.clear();
    expiresAt.value = null;
    selectedPlan.value = null;
  }

  void loadPlanForEdit(DonationPlanEntity plan) {
    selectedPlan.value = plan;
    titleController.text = plan.title;
    descriptionController.text = plan.description ?? '';
    provinceController.text = plan.province;
    districtController.text = plan.district ?? '';
    requiredItems.value = List.from(plan.requiredItems);
    expiresAt.value = plan.expiresAt;
  }
}

