import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile/update_contact_controller.dart';

class ChangeContact extends StatelessWidget {
  const ChangeContact({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateContactController());

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text("Cập nhật liên hệ"),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                validator: (v) =>
                    MinhValidator.validateEmptyText("Số điện thoại", v),
              ),
              const SizedBox(height: MinhSizes.spaceBtwInputFields),
              const SizedBox(height: MinhSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.updateContact(),
                  child: const Text("Lưu"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
