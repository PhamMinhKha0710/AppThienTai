import 'package:cuutrobaolu/presentation/features/authentication/controllers/signup/signup_controller.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupForm_Checkbox extends StatelessWidget {
  const SignupForm_Checkbox({
    super.key,
    this.isDark = false,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;

    final linkColor = isDark 
        ? const Color(0xFF5EEAD4) 
        : const Color(0xFF0D9488);
    
    final textColor = isDark 
        ? Colors.white70 
        : Colors.grey.shade600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: controller.privacyPolicy.value,
                onChanged: (value) {
                  controller.privacyPolicy.value = !controller.privacyPolicy.value;
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
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: MinhTexts.iAgreeTo,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ' ${MinhTexts.privacyPolicy} ',
                  style: TextStyle(
                    color: linkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: linkColor,
                  ),
                ),
                TextSpan(
                  text: MinhTexts.and,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ' ${MinhTexts.termsOfUse}',
                  style: TextStyle(
                    color: linkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: linkColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
