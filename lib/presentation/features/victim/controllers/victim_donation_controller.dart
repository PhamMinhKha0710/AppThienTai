import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:flutter/material.dart';

class VictimDonationController extends GetxController {
  final selectedTab = 0.obs;
  final paymentMethod = 'wallet'.obs;
  final totalDonation = 10000000.0.obs; // TODO: Load from Firestore

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
    super.onClose();
  }

  void loadTotalDonation() {
    // TODO: Load from Firestore
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

      // TODO: Process payment
      // - Integrate with VNPay/Momo
      // - Save to Firestore
      // - Update total donation

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

      // TODO: Save to Firestore
      // - Create donation record
      // - Update transparency log

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Quyên góp của bạn đã được ghi nhận. Cảm ơn bạn!",
      );

      // Clear form
      itemNameController.clear();
      quantityController.clear();
      itemDescriptionController.clear();
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể quyên góp: $e",
      );
    }
  }
}


