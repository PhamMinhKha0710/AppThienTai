import 'package:cuutrobaolu/features/authentication/screens/singup/widget/SingUpForm_Checkbox.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/enums.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/signup/signup_controller.dart';
import '../verifi_email.dart';

class SingUpFrom extends StatelessWidget {
  const SingUpFrom({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Form(
      key: controller.signUpFormKey,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: MinhSizes.spaceBtwSections,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Obx(
              () => controller.error.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(MinhSizes.md),
                      margin: const EdgeInsets.only(bottom: MinhSizes.md),
                      decoration: BoxDecoration(
                        color: MinhColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(MinhSizes.md),
                        border: Border.all(color: MinhColors.error),
                      ),
                      child: Text(
                        controller.error.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MinhColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox(),
            ),

            // name
            Row(
              children: [
                // Name
                Expanded(
                  child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) {
                      return MinhValidator.validateEmptyText(
                        "First Name",
                        value,
                      );
                    },
                    expands: false,
                    decoration: InputDecoration(
                      labelText: MinhTexts.firstName,
                      prefixIcon: Icon(Iconsax.user),
                    ),
                  ),
                ),
                SizedBox(width: MinhSizes.spaceBtwInputFields),
                Expanded(
                  child: TextFormField(
                    controller: controller.lastName,
                    validator: (value) {
                      return MinhValidator.validateEmptyText(
                        "Last Name",
                        value,
                      );
                    },
                    expands: false,
                    decoration: InputDecoration(
                      labelText: MinhTexts.lastName,
                      prefixIcon: Icon(Iconsax.user),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // User Type Selection - TRƯỜNG MỚI THÊM
            Obx(
                  () => DropdownButtonFormField<UserType>(
                value: controller.selectedUserType.value,
                onChanged: (UserType? newValue) {
                  controller.selectedUserType.value = newValue!;
                },
                decoration: const InputDecoration(
                  labelText: 'Loại người dùng',
                  prefixIcon: Icon(Iconsax.profile_2user),
                ),
                items: UserType.values.map((UserType type) {
                  return DropdownMenuItem<UserType>(
                    value: type,
                    child: Text(type.viName), // Sử dụng viName từ enum
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // Username
            TextFormField(
              controller: controller.userName,
              validator: (value) {
                return MinhValidator.validateUsername(value);
              },
              expands: false,
              decoration: InputDecoration(
                labelText: MinhTexts.username,
                prefixIcon: Icon(Iconsax.user_edit),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // Email
            TextFormField(
              controller: controller.email,
              validator: (value) {
                return MinhValidator.validateEmail(value);
              },
              expands: false,
              decoration: InputDecoration(
                labelText: MinhTexts.email,
                prefixIcon: Icon(Iconsax.direct),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // Phone
            TextFormField(
              controller: controller.phoneNumber,
              validator: (value) {
                return MinhValidator.validatePhoneNumber(value);
              },
              expands: false,
              decoration: InputDecoration(
                labelText: MinhTexts.phoneNo,
                prefixIcon: Icon(Iconsax.call),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // Password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) {
                  return MinhValidator.validatePassword(value);
                },
                obscureText: controller.hiddenPassword.value,
                decoration: InputDecoration(
                  labelText: MinhTexts.password,
                  prefixIcon: Icon(Iconsax.password_check),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      controller.hiddenPassword.value =
                          !controller.hiddenPassword.value;
                    },
                    child: controller.hiddenPassword.value == true
                        ? Icon(Iconsax.eye_slash)
                        : Icon(Iconsax.eye),
                  ),
                ),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // Confirm Password
            Obx(
                  () => TextFormField(
                controller: controller.confirmPassword,
                validator: (value) => MinhValidator.validateConfirmPassword(
                  controller.password.text,
                  value,
                ),
                obscureText: controller.hiddenConfirmPassword.value,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: controller.toggleConfirmPasswordVisibility,
                    icon: Icon(
                      controller.hiddenConfirmPassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // checkbox
            SignupForm_Checkbox(),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.signup();
                },
                child: Text(MinhTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
