import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/data/repositories/donations/donation_repository.dart';
import 'package:flutter/material.dart';

class VictimDonationController extends GetxController {
  final DonationRepository _donationRepo = DonationRepository();

  final selectedTab = 0.obs;
  final paymentMethod = 'wallet'.obs;
  final totalDonation = 0.0.obs;

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
      );

      // TODO: Process payment with VNPay/Momo
      // After payment success, update status to 'completed'
      await _donationRepo.updateDonationStatus(donationId, 'completed');

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

      // Create donation record
      final donationId = await _donationRepo.createSuppliesDonation(
        itemName: itemNameController.text.trim(),
        quantity: quantity,
        description: itemDescriptionController.text.trim(),
      );

      // Update status to completed
      await _donationRepo.updateDonationStatus(donationId, 'completed');

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
