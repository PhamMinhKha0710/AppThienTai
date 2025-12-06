import 'package:cuutrobaolu/core/widgets/styles/MinhSpaceingStyle.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:cuutrobaolu/core/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/forget_password/forget_password_controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ForgetPasswordController());

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
          padding: MinhSpaceingStyle.paddingWithApparHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Heading
              Text(
                MinhTexts.forgetPassword,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: MinhSizes.spaceBtwItems,),
              Text(
                MinhTexts.forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: MinhSizes.spaceBtwSections *2,),

              // TextFormField
              Form(
                key: controller.forgetPasswordFormKey,
                child: TextFormField(
                  controller: controller.email,
                  expands: false,
                  validator: (value) => MinhValidator.validateEmptyText("Forget Password", value),
                  decoration: InputDecoration(
                    labelText: MinhTexts.email,
                    suffixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwSections,),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      controller.sendPasswordResetEmail();
                    },
                    child: Text(
                      MinhTexts.forgetPassword
                    ),
                ),
              ),

            ],
          ),
      ),
    );
  }
}

