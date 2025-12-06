import 'package:cuutrobaolu/common/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ReAuthLoginForm extends StatelessWidget {
  const ReAuthLoginForm({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = UserController.instance;

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Re-Authenticate User"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MinhSizes.defaultSpace),
          child: Form(
            key: controller.reAuthFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.verifyEmail,
                  validator: (value) =>  MinhValidator.validateEmail(value),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Iconsax.direct_right),
                      labelText: MinhTexts.email
                  ),
                ),
                SizedBox(height: MinhSizes.spaceBtwInputFields,),
                Obx(
                    () =>  TextFormField(
                      controller: controller.verifyPassword,
                      validator: (value) =>  MinhValidator.validateEmptyText("Password",value),
                      obscureText: controller.hiddenPassword.value,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Iconsax.password_check),
                          suffixIcon: IconButton(
                              icon: Icon(Iconsax.eye_slash),
                              onPressed: (){
                                controller.hiddenPassword.value = !controller.hiddenPassword.value;
                              },
                          ),
                          labelText: MinhTexts.password
                      ),
                    ),
                ),

                SizedBox(height: MinhSizes.spaceBtwSections,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: (){
                        controller.reAuthenticateEmailAndPasswordUser();
                      },
                      child: Text("Okeyyyy !"),
                  ),
                ),


              ],

            ),
          ),
        ),
      ),
    );
  }
}
