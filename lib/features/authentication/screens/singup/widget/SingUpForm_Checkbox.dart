import 'package:cuutrobaolu/features/authentication/controllers/signup/signup_controller.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupForm_Checkbox extends StatelessWidget {
  const SignupForm_Checkbox({
    super.key,

  });


  @override
  Widget build(BuildContext context) {

    final controller = SignupController.instance;

    bool isDark = MinhHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () =>  Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) {
                controller.privacyPolicy.value = !controller.privacyPolicy.value;
              },
            ),
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text:MinhTexts.iAgreeTo,
                  style: Theme.of(context).textTheme.bodySmall
              ),
              TextSpan(
                text: '  ${MinhTexts.privacyPolicy}  ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: isDark ? MinhColors.white : MinhColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: isDark ? MinhColors.white : MinhColors.primary,
                ),
              ),
              TextSpan(
                  text: MinhTexts.and,
                  style: Theme.of(context).textTheme.bodySmall
              ),
              TextSpan(
                text: '  ${MinhTexts.termsOfUse}  ',
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: isDark ? MinhColors.white : MinhColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: isDark ? MinhColors.white : MinhColors.primary,
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}