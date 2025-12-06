import 'package:cuutrobaolu/common/widgets/login_singup/MinhFromButtonSocial.dart';
import 'package:cuutrobaolu/common/widgets/login_singup/MinhFromDriver.dart';
import 'package:cuutrobaolu/features/authentication/screens/singup/widget/SingUpFrom.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/constants/text_strings.dart';
import 'package:flutter/material.dart';


class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(MinhSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Title
              Text(
                MinhTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: MinhSizes.spaceBtwSections,),

              // From
              SingUpFrom(),
              SizedBox(height: MinhSizes.spaceBtwSections,),

              // Driver
              MinhFromDriver(driverText: MinhTexts.createAccount),
              SizedBox(height: MinhSizes.spaceBtwSections,),

              // facebook, gmail - footer
              MinhFromButtonSocial(),

            ],
          ),
        ),
      ),
    );
  }
}


