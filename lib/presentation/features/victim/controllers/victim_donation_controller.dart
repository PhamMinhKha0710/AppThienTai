import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/domain/repositories/donation_repository.dart';
import 'package:cuutrobaolu/domain/entities/donation_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/core/constants/supply_categories.dart';
import 'package:flutter/material.dart';

class VictimDonationController extends GetxController {
  final DonationRepository _donationRepo = getIt<DonationRepository>();

  final selectedTab = 0.obs;
  final paymentMethod = 'wallet'.obs;
  final totalDonation = 0.0.obs;

  // Donation target selection
  final donationTargetType = 'general'.obs; // 'general', 'alert', 'area'
  final selectedAlertId = Rxn<String>();
  final selectedProvince = Rxn<String>();
  final selectedDistrict = Rxn<String>();

  // Supply category
  final selectedCategory = Rxn<SupplyCategory>();
  final customCategoryController = TextEditingController();

  final amountController = TextEditingController();
  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final itemDescriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTotalDonation();
  }

  @override
  void onClose() {
    amountController.dispose();
    itemNameController.dispose();
    quantityController.dispose();
    itemDescriptionController.dispose();
    customCategoryController.dispose();
    super.onClose();
  }

  Future<void> loadTotalDonation() async {
    try {
      final total = await _donationRepo.getTotalMoneyDonations();
      totalDonation.value = total;
    } catch (e) {
      print('Error loading total donation: $e');
    }
  }

  Future<void> submitMoneyDonation() async {
    if (amountController.text.trim().isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng nhập số tiền",
      );
      return;
    }

    try {
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        throw Exception("Số tiền không hợp lệ");
      }

      // Create donation record
      final donationId = await _donationRepo.createMoneyDonation(
        amount: amount,
        paymentMethod: paymentMethod.value,
        alertId: donationTargetType.value == 'alert' ? selectedAlertId.value : null,
        province: donationTargetType.value == 'area' ? selectedProvince.value : null,
        district: donationTargetType.value == 'area' ? selectedDistrict.value : null,
      );

      // TODO: Process payment with VNPay/Momo
      // After payment success, update status to 'completed'
      await _donationRepo.updateDonationStatus(donationId, DonationStatus.completed);

      // Reload total
      await loadTotalDonation();

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Quyên góp của bạn đã được ghi nhận. Cảm ơn bạn!",
      );

      // Clear form
      amountController.clear();
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể quyên góp: $e",
      );
    }
  }

  Future<void> submitSuppliesDonation() async {
    if (itemNameController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng điền đầy đủ thông tin",
      );
      return;
    }

    try {
      final quantity = int.tryParse(quantityController.text);
      if (quantity == null || quantity <= 0) {
        throw Exception("Số lượng không hợp lệ");
      }

      // Validate category
      if (selectedCategory.value == null) {
        MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Vui lòng chọn danh mục vật phẩm",
        );
        return;
      }

      String? customCategory;
      if (selectedCategory.value == SupplyCategory.other) {
        if (customCategoryController.text.trim().isEmpty) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Vui lòng nhập tên danh mục tùy chỉnh",
          );
          return;
        }
        customCategory = customCategoryController.text.trim();
      }

      // Create donation record
      final donationId = await _donationRepo.createSuppliesDonation(
        itemName: itemNameController.text.trim(),
        quantity: quantity,
        description: itemDescriptionController.text.trim(),
        category: selectedCategory.value,
        customCategory: customCategory,
        alertId: donationTargetType.value == 'alert' ? selectedAlertId.value : null,
        province: donationTargetType.value == 'area' ? selectedProvince.value : null,
        district: donationTargetType.value == 'area' ? selectedDistrict.value : null,
      );

      // Update status to completed
      await _donationRepo.updateDonationStatus(donationId, DonationStatus.completed);

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Quyên góp của bạn đã được ghi nhận. Cảm ơn bạn!",
      );

      // Clear form
      itemNameController.clear();
      quantityController.clear();
      itemDescriptionController.clear();
      selectedCategory.value = null;
      customCategoryController.clear();
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể quyên góp: $e",
      );
    }
  }
}
