import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/data/repositories/donations/donation_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VolunteerDonationController extends GetxController {
  final DonationRepository _donationRepo = DonationRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final selectedTab = 0.obs; // 0: Money, 1: Supplies, 2: Time
  final paymentMethod = 'wallet'.obs;
  final totalDonation = 0.0.obs;
  final totalTimeDonated = 0.0.obs;

  final amountController = TextEditingController();
  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  
  // Time donation fields
  final hoursController = TextEditingController();
  final dateController = TextEditingController();
  final timeDescriptionController = TextEditingController();
  final selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadDonationData();
  }

  @override
  void onClose() {
    amountController.dispose();
    itemNameController.dispose();
    quantityController.dispose();
    itemDescriptionController.dispose();
    hoursController.dispose();
    dateController.dispose();
    timeDescriptionController.dispose();
    super.onClose();
  }

  Future<void> loadDonationData() async {
    try {
      // Load total money donations
      final total = await _donationRepo.getTotalMoneyDonations();
      totalDonation.value = total;

      // Load total time donated by current user
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final time = await _donationRepo.getTotalTimeDonated(userId);
        totalTimeDonated.value = time;
      }
    } catch (e) {
      print('Error loading donation data: $e');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = "${picked.day}/${picked.month}/${picked.year}";
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

      // Reload totals
      await loadDonationData();

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

  Future<void> submitTimeDonation() async {
    if (hoursController.text.trim().isEmpty ||
        selectedDate.value == null) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng điền đầy đủ thông tin",
      );
      return;
    }

    try {
      final hours = double.tryParse(hoursController.text);
      if (hours == null || hours <= 0) {
        throw Exception("Số giờ không hợp lệ");
      }

      // Create time donation record
      final donationId = await _donationRepo.createTimeDonation(
        hours: hours,
        date: selectedDate.value!,
        description: timeDescriptionController.text.trim(),
      );

      // Update status to completed
      await _donationRepo.updateDonationStatus(donationId, 'completed');

      // Reload totals
      await loadDonationData();

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Đăng ký quyên góp thời gian của bạn đã được ghi nhận. Cảm ơn bạn!",
      );

      // Clear form
      hoursController.clear();
      dateController.clear();
      timeDescriptionController.clear();
      selectedDate.value = null;
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể đăng ký: $e",
      );
    }
  }
}
