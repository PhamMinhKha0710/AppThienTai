import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:cuutrobaolu/core/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/profile/update_name_controller.dart';

class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(UpdateNameController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text(
          "Change Name",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Use real name for easy verification. This will appear on several pages",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: MinhSizes.spaceBtwSections,),
            Form(
              key: controller.updateNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.firstName,
                    validator: (value) => MinhValidator.validateEmptyText("First Name", value),
                    expands: false,
                    decoration: InputDecoration(labelText: MinhTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwInputFields,),
                  TextFormField(
                    controller: controller.lastName,
                    validator: (value) => MinhValidator.validateEmptyText("Last Name", value),
                    expands: false,
                    decoration: InputDecoration(labelText: MinhTexts.lastName, prefixIcon: Icon(Iconsax.user)),
                  ),

                ],
              ),
            ),

            SizedBox(height: MinhSizes.spaceBtwSections,),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.updateUserName();
                },
                child: Text("Save")
               ),
            ),
          ],
        ),
      ),
    );
  }
}

