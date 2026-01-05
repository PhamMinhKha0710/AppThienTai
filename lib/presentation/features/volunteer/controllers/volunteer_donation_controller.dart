import 'package:get/get.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/domain/repositories/donation_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/domain/entities/donation_entity.dart';
import 'package:cuutrobaolu/core/constants/supply_categories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VolunteerDonationController extends GetxController {
  final DonationRepository _donationRepo = getIt<DonationRepository>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final selectedTab = 0.obs; // 0: Money, 1: Supplies, 2: Time
  final paymentMethod = 'wallet'.obs;
  final totalDonation = 0.0.obs;
  final totalTimeDonated = 0.0.obs;

  // Quick Amount logic
  final quickAmounts = [50000, 100000, 200000, 500000, 1000000, 2000000];
  final selectedQuickAmount = Rxn<int>();
  
  // QR Code logic
  final showQrCode = false.obs;
  final isProcessingPayment = false.obs;

  // Donation target selection
  final donationTargetType = 'general'.obs; // 'general', 'alert', 'area'
  final selectedAlertId = Rxn<String>();
  final selectedProvince = Rxn<String>();
  final selectedDistrict = Rxn<String>();
  
  // Selected campaign (for UI)
  final selectedCampaignId = Rxn<String>();

  // Supply category
  final selectedCategory = Rxn<SupplyCategory>();
  final customCategoryController = TextEditingController();

  final amountController = TextEditingController();
  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  
  // Time/Effort donation fields
  final hoursController = TextEditingController(); 
  // We keep hoursController for backward compatibility or backend requirement, 
  // but logically we might send a fixed value or calculated value
  
  final dateController = TextEditingController();
  final timeDescriptionController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  
  // Volunteer Skills
  final selectedSkills = <String>[].obs;
  final availableSkills = [
    'Vận chuyển', 
    'Y tế/Sơ cấp cứu', 
    'Dọn dẹp/Vệ sinh', 
    'Nấu ăn/Hậu cần', 
    'Cứu hộ/Bơi lội',
    'Phân phát nhu yếu phẩm'
  ];
  
  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadDonationData();
    // Listen to amount changes to clear quick select if manual input
    amountController.addListener(() {
      if (selectedQuickAmount.value != null) {
        final textVal = double.tryParse(amountController.text.replaceAll(',', ''));
        if (textVal != null && textVal != selectedQuickAmount.value!.toDouble()) {
          selectedQuickAmount.value = null;
        }
      }
    });
  }

  @override
  void onClose() {
    amountController.dispose();
    itemNameController.dispose();
    quantityController.dispose();
    itemDescriptionController.dispose();
    customCategoryController.dispose();
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

  /// Select a quick amount chip
  void selectQuickAmount(int amount) {
    selectedQuickAmount.value = amount;
    amountController.text = amount.toStringAsFixed(0);
  }

  /// Start mock payment flow
  Future<void> processQrPayment(BuildContext context) async {
    if (amountController.text.trim().isEmpty) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: "Vui lòng nhập số tiền");
      return;
    }
    
    final amount = double.tryParse(amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: "Số tiền không hợp lệ");
      return;
    }
    
    // Show QR Dialog
    showQrCode.value = true;
    
    // In a real app, we would listen to payment socket/webhook here
    // For now, we wait for user to click "I have paid"
  }

  /// Verification call (Mock)
  Future<void> verifyPayment() async {
    isProcessingPayment.value = true;
    
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    isProcessingPayment.value = false;
    showQrCode.value = false;
    
    // Proceed to submit donation
    await submitMoneyDonation(bypassPayment: true);
  }

  Future<void> submitMoneyDonation({bool bypassPayment = false}) async {
    if (amountController.text.trim().isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng nhập số tiền",
      );
      return;
    }

    try {
      final amount = double.tryParse(amountController.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) {
        throw Exception("Số tiền không hợp lệ");
      }
      
      // If payment not verified yet and method is wallet/bank, verify first
      if (!bypassPayment && (paymentMethod.value == 'wallet' || paymentMethod.value == 'bank')) {
        // Trigger verification UI flow
         // Ideally controlled from UI, but here we can just return
         return;
      }

      // Create donation record
      final donationId = await _donationRepo.createMoneyDonation(
        amount: amount,
        paymentMethod: paymentMethod.value,
        alertId: donationTargetType.value == 'alert' ? selectedAlertId.value : null,
        province: donationTargetType.value == 'area' ? selectedProvince.value : null,
        district: donationTargetType.value == 'area' ? selectedDistrict.value : null,
      );

      // Status is completed because we verified payment (mock)
      await _donationRepo.updateDonationStatus(donationId, DonationStatus.completed);

      // Reload totals
      await loadDonationData();

      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Quyên góp của bạn đã được ghi nhận. Cảm ơn bạn!",
      );

      // Clear form
      amountController.clear();
      selectedQuickAmount.value = null;
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
        alertId: donationTargetType.value == 'alert' ? selectedAlertId.value : null,
        province: donationTargetType.value == 'area' ? selectedProvince.value : null,
        district: donationTargetType.value == 'area' ? selectedDistrict.value : null,
      );

      // Update status to completed
      await _donationRepo.updateDonationStatus(donationId, DonationStatus.completed);

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
