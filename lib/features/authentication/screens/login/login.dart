import 'package:cuutrobaolu/common/styles/MinhSpaceingStyle.dart';
import 'package:cuutrobaolu/common/widgets/login_singup/MinhFromDriver.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/widget/LoginFooter.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/widget/LoginForm.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/widget/LoginHeader.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: MinhSpaceingStyle.paddingWithApparHeight,
            child: Column(
              children: [
                // hình ảnh, tiêu đề
                LoginHeader(isDark: isDark),

                // from
                LoginForm(),

                // Driver - cái đường:  -------------- nd -----------------
                // LoginDriver(isDark: isDark), // cái 1
                MinhFromDriver(driverText: MinhTexts.orSignInWith.capitalize!), // cái 2
                SizedBox(height: MinhSizes.spaceBtwSections,),

                // footer
                LoginFooter(),
              ],
            ),
        ),
      ),
    );
  }
}










