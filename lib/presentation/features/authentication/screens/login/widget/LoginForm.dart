import 'package:cuutrobaolu/core/constants/auth_theme.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/singup/singup.dart';
import 'package:cuutrobaolu/core/utils/validation.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login/login_controller.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    this.isDark = false,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormkey,
      child: Column(
        children: [
          // Email Field
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

          const SizedBox(height: 20),

          // Password Field
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => MinhValidator.validateEmptyText("Mật khẩu", value),
              obscureText: controller.hidePassword.value,
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
                    controller.hidePassword.value = !controller.hidePassword.value;
                  },
                  child: Icon(
                    controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye,
                    color: isDark ? Colors.white60 : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember Me
              Row(
                children: [
                  Obx(
                    () => Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (value) {
                          controller.rememberMe.value = !controller.rememberMe.value;
                        },
                        activeColor: const Color(0xFF14B8A6),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    MinhTexts.rememberMe,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Forgot Password
              TextButton(
                onPressed: () => Get.to(() => ForgetPasswordScreen()),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF14B8A6),
                ),
                child: Text(
                  MinhTexts.forgetPassword,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0D9488),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Sign In Button (Gradient)
          AuthTheme.gradientButton(
            onPressed: () => controller.emailAndPasswordSignIn(),
            text: MinhTexts.signIn,
          ),

          const SizedBox(height: 16),

          // Create Account Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.3) 
                    : const Color(0xFF0D9488).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: TextButton(
              onPressed: () => Get.to(() => SignupScreen()),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                MinhTexts.createAccount,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0D9488),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
