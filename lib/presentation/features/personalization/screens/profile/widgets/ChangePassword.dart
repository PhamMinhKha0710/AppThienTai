import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile/change_password_controller.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      appBar: MinhAppbar(title: const Text('Đổi mật khẩu'), showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          children: [
            TextField(
              controller: controller.currentPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
            ),
            const SizedBox(height: MinhSizes.spaceBtwInputFields),
            TextField(
              controller: controller.newPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
            const SizedBox(height: MinhSizes.spaceBtwInputFields),
            TextField(
              controller: controller.confirmPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
            ),
            const SizedBox(height: MinhSizes.spaceBtwSections),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () => controller.changePassword(),
                child: controller.isSubmitting.value ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Lưu'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}



