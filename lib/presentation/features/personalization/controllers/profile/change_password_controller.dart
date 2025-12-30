import 'package:cuutrobaolu/domain/usecases/re_authenticate_usecase.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get instance => Get.find();

  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final isSubmitting = false.obs;

  ReAuthenticateUseCase get _reAuth => Get.find<ReAuthenticateUseCase>();

  Future<void> changePassword() async {
    try {
      if (newPassword.text.trim().isEmpty ||
          currentPassword.text.trim().isEmpty) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Vui lòng điền mật khẩu hiện tại và mật khẩu mới',
        );
        return;
      }
      if (newPassword.text.trim() != confirmPassword.text.trim()) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Mật khẩu xác nhận không khớp',
        );
        return;
      }

      isSubmitting.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Người dùng chưa đăng nhập',
        );
        isSubmitting.value = false;
        return;
      }

      // Re-authenticate
      await _reAuth(user.email!, currentPassword.text.trim());

      // Update password
      await user.updatePassword(newPassword.text.trim());

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đổi mật khẩu thành công',
      );
      Get.back();
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể đổi mật khẩu: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
