import 'dart:io';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/usecases/create_help_request_usecase.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/presentation/utils/help_request_mapper.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:flutter/material.dart';

class VictimSosController extends GetxController {
  LocationService? _locationService;
  final CreateHelpRequestUseCase _createHelpRequestUseCase = Get.find<CreateHelpRequestUseCase>();
  
  final currentStep = 0.obs;
  final descriptionController = TextEditingController();
  final currentPosition = Rxn<Position>();
  final selectedImages = <File>[].obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    getCurrentLocation();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }
    final position = await _locationService?.getCurrentLocation();
    currentPosition.value = position;
  }

  void nextStep() {
    if (currentStep.value < 2) {
      if (currentStep.value == 0) {
        // Validate description
        if (descriptionController.text.trim().isEmpty) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Vui lòng nhập mô tả vấn đề",
          );
          return;
        }
      }
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể chọn hình ảnh: $e",
      );
    }
  }

  void removeImage(File image) {
    selectedImages.remove(image);
  }

  Future<void> submitSOS() async {
    // Validate description first
    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Vui lòng nhập mô tả vấn đề",
      );
      return;
    }

    // Ensure we have location
    if (currentPosition.value == null) {
      MinhLoaders.warningSnackBar(
        title: "Đang lấy vị trí...",
        message: "Vui lòng đợi trong giây lát",
      );
      // Try to get location
      await getCurrentLocation();
      if (currentPosition.value == null) {
        MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Không thể lấy vị trí hiện tại. Vui lòng kiểm tra quyền truy cập vị trí.",
        );
        return;
      }
    }

    isSubmitting.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Người dùng chưa đăng nhập");
      }

      // TODO: Upload images to Firebase Storage
      String? imageUrl;
      if (selectedImages.isNotEmpty) {
        // Upload first image as example
        // imageUrl = await uploadImage(selectedImages.first);
      }

      // Get address from position - ensure it's not empty
      String address = _locationService?.currentAddress.value ?? "";
      if (address.isEmpty || address.trim().isEmpty) {
        // Try to get address from coordinates using LocationService
        try {
          final position = currentPosition.value!;
          final fetchedAddress = await _locationService?.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (fetchedAddress != null && fetchedAddress.isNotEmpty) {
            address = fetchedAddress;
          } else {
            // Fallback to coordinates
            address = "Vị trí GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
          }
        } catch (e) {
          // Fallback to coordinates
          final position = currentPosition.value!;
          address = "Vị trí GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
        }
      }

      // Get contact - ensure it's not empty
      String contact = user.phoneNumber ?? user.email ?? "";
      if (contact.isEmpty || contact.trim().isEmpty) {
        contact = user.uid; // Fallback to user ID if no phone/email
      }

      // Create help request
      final helpRequest = HelpRequest(
        id: "",
        title: "SOS Khẩn cấp",
        description: description,
        lat: currentPosition.value!.latitude,
        lng: currentPosition.value!.longitude,
        contact: contact,
        address: address,
        imageUrl: imageUrl,
        userId: user.uid,
        severity: RequestSeverity.urgent,
        type: RequestType.rescue,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      // Convert to Entity and use Use Case
      final helpRequestEntity = HelpRequestMapper.toEntity(helpRequest);
      await _createHelpRequestUseCase(helpRequestEntity);

      isSubmitting.value = false;

      Get.back();
      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Yêu cầu SOS đã được gửi. Chúng tôi sẽ liên hệ với bạn sớm nhất.",
      );
    } on ValidationFailure catch (e) {
      isSubmitting.value = false;
      MinhLoaders.errorSnackBar(
        title: "Lỗi xác thực",
        message: e.message,
      );
    } on Failure catch (e) {
      isSubmitting.value = false;
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: e.message,
      );
    } catch (e) {
      isSubmitting.value = false;
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Không thể gửi yêu cầu: ${e.toString()}",
      );
    }
  }
}

