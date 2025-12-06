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
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormkey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MinhSizes.spaceBtwSections.toDouble(),
        ),
        child: Column(
          children: [
            // email
            TextFormField(
              controller: controller.email,
              validator: (value) {
                return MinhValidator.validateEmail(value);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: MinhTexts.email,
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),
            // mật khẩu
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) {
                  return MinhValidator.validateEmptyText("Password", value);
                },
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.password_check),
                  suffixIcon: GestureDetector(
                    onTap: (){
                      controller.hidePassword.value = !controller.hidePassword.value;
                    },
                    child: controller.hidePassword.value == true
                                          ? Icon(Iconsax.eye_slash)
                                          : Icon(Iconsax.eye),
                  ),
                  labelText: MinhTexts.password,
                ),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwInputFields),

            // ghi nhớ tôi và chắc chắn mật khẩu,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ghi nhớ
                Row(
                  children: [
                    Obx(
                          () => Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: (value) {
                                controller.rememberMe.value = !controller.rememberMe.value;
                              }
                          ),
                    ),
                    Text(MinhTexts.rememberMe),
                  ],
                ),
                // chắc chắn
                TextButton(
                  onPressed: () {
                    Get.to(() => ForgetPasswordScreen());
                  },
                  child: Text(MinhTexts.forgetPassword),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwSections),

            // nút đăng nhập
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.emailAndPasswordSignIn();
                },
                child: Text(MinhTexts.signIn),
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // nút tạo tài khoản
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(() => SignupScreen());
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

