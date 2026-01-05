import 'package:cuutrobaolu/core/constants/auth_theme.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/singup/widget/SingUpForm_Checkbox.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:cuutrobaolu/core/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/signup/signup_controller.dart';
import '../verifi_email.dart';

class SingUpFrom extends StatelessWidget {
  const SingUpFrom({
    super.key,
    this.isDark = false,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Form(
      key: controller.signUpFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Error message
          Obx(
            () => controller.error.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(MinhSizes.md),
                    margin: const EdgeInsets.only(bottom: MinhSizes.md),
                    decoration: BoxDecoration(
                      color: MinhColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MinhColors.error.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.warning_2, color: MinhColors.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.error.value,
                            style: TextStyle(
                              color: MinhColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),

          // Name Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: (value) => MinhValidator.validateEmptyText("Họ", value),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: AuthTheme.glassInputDecoration(
                    labelText: MinhTexts.firstName,
                    prefixIcon: Iconsax.user,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: (value) => MinhValidator.validateEmptyText("Tên", value),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: AuthTheme.glassInputDecoration(
                    labelText: MinhTexts.lastName,
                    prefixIcon: Iconsax.user,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Type Dropdown
          Obx(
            () => DropdownButtonFormField<UserType>(
              value: controller.selectedUserType.value,
              onChanged: (UserType? newValue) {
                controller.selectedUserType.value = newValue!;
              },
              dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              decoration: AuthTheme.glassInputDecoration(
                labelText: 'Loại người dùng',
                prefixIcon: Iconsax.profile_2user,
                isDark: isDark,
              ),
              items: UserType.values.map((UserType type) {
                return DropdownMenuItem<UserType>(
                  value: type,
                  child: Text(
                    type.viName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Username
          TextFormField(
            controller: controller.userName,
            validator: (value) => MinhValidator.validateUsername(value),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
            decoration: AuthTheme.glassInputDecoration(
              labelText: MinhTexts.username,
              prefixIcon: Iconsax.user_edit,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: controller.email,
            validator: (value) => MinhValidator.validateEmail(value),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
            decoration: AuthTheme.glassInputDecoration(
              labelText: MinhTexts.email,
              prefixIcon: Iconsax.sms,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: controller.phoneNumber,
            validator: (value) => MinhValidator.validatePhoneNumber(value),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
            decoration: AuthTheme.glassInputDecoration(
              labelText: MinhTexts.phoneNo,
              prefixIcon: Iconsax.call,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => MinhValidator.validatePassword(value),
              obscureText: controller.hiddenPassword.value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              decoration: AuthTheme.glassInputDecoration(
                labelText: MinhTexts.password,
                prefixIcon: Iconsax.lock,
                isDark: isDark,
                suffixIcon: GestureDetector(
                  onTap: () {
                    controller.hiddenPassword.value = !controller.hiddenPassword.value;
                  },
                  child: Icon(
                    controller.hiddenPassword.value ? Iconsax.eye_slash : Iconsax.eye,
                    color: isDark ? Colors.white60 : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirm Password
          Obx(
            () => TextFormField(
              controller: controller.confirmPassword,
              validator: (value) => MinhValidator.validateConfirmPassword(
                controller.password.text,
                value,
              ),
              obscureText: controller.hiddenConfirmPassword.value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              decoration: AuthTheme.glassInputDecoration(
                labelText: 'Xác nhận mật khẩu',
                prefixIcon: Iconsax.lock_1,
                isDark: isDark,
                suffixIcon: GestureDetector(
                  onTap: controller.toggleConfirmPasswordVisibility,
                  child: Icon(
                    controller.hiddenConfirmPassword.value ? Iconsax.eye_slash : Iconsax.eye,
                    color: isDark ? Colors.white60 : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Checkbox
          SignupForm_Checkbox(isDark: isDark),

          const SizedBox(height: 24),

          // Submit Button
          AuthTheme.gradientButton(
            onPressed: () => controller.signup(),
            text: MinhTexts.createAccount,
          ),
        ],
      ),
    );
  }
}
