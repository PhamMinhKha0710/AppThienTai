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

  static VictimSosController get to => Get.find();

  // final CreateHelpRequestUseCase _createHelpRequestUseCase = Get.find<CreateHelpRequestUseCase>();


  final currentStep = 0.obs;
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final numberOfPeopleController = TextEditingController();
  final currentPosition = Rxn<Position>();
  final selectedImages = <File>[].obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    getCurrentLocation();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load phone number if available
        if (user.phoneNumber != null) {
          phoneController.text = user.phoneNumber!;
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
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
    phoneController.dispose();
    addressController.dispose();
    numberOfPeopleController.dispose();
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
    if (currentStep.value < 3) {
      if (currentStep.value == 0) {
        // Validate description
        if (descriptionController.text.trim().isEmpty) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Vui lòng nhập mô tả vấn đề",
          );
          return;
        }
        // Validate location
        if (currentPosition.value == null) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Vui lòng đợi hệ thống lấy vị trí",
          );
          return;
        }
      } else if (currentStep.value == 1) {
        // Validate phone
        if (phoneController.text.trim().isEmpty) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Vui lòng nhập số điện thoại liên lạc",
          );
          return;
        }
        // Validate number of people
        if (numberOfPeopleController.text.trim().isEmpty) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Vui lòng nhập số người cần hỗ trợ",
          );
          return;
        }
        final numPeople = int.tryParse(numberOfPeopleController.text.trim());
        if (numPeople == null || numPeople <= 0) {
          MinhLoaders.errorSnackBar(
            title: "Lỗi",
            message: "Số người phải là số nguyên dương",
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

      // Get address - prioritize manual input, then location service, then coordinates
      String address = addressController.text.trim();
      if (address.isEmpty) {
        address = _locationService?.currentAddress.value ?? "";
        if (address.isEmpty) {
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
      }

      // Get contact - prioritize phone input, then user phone, then email
      String contact = phoneController.text.trim();
      if (contact.isEmpty) {
        contact = user.phoneNumber ?? user.email ?? "";
        if (contact.isEmpty) {
          contact = user.uid; // Fallback to user ID if no phone/email
        }
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

