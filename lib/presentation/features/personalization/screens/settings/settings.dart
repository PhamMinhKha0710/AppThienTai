
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhUserProfileTitle.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/domain/usecases/logout_usecase.dart';
import 'package:cuutrobaolu/domain/repositories/authentication_repository.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/settings/upload_data/upload_data.dart';

import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../address/address.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            // header
            MinhPrimaryHeaderContainer(
              child: Column(
                children: [
                  MinhAppbar(
                    title: Text(
                      "Account",
                      style: Theme.of(context).textTheme.headlineMedium!.apply(
                        color: MinhColors.white,
                      ),
                    ),
                    action: [],
                  ),

                  MinhUserProfileTitle(
                    onPressed: (){
                      Get.to(()=> ProfileScreen());
                    },
                  ),


                  SizedBox(height: MinhSizes.spaceBtwSections),
                ],
              ),
            ),

            SizedBox(height: MinhSizes.spaceBtwItems),

            // Body

            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                children: [
                  MinhSectionHeading(
                      title: "Account Settings",
                      showActionButton: false,
                  ),

                  SizedBox(height: MinhSizes.spaceBtwItems,),

                  MinhSettingsMenuTitle(
                      icon: Iconsax.safe_home,
                      title: "My address",
                      subtitle: "Set Shopping delivery address",
                      onTap: (){
                        Get.to(()=> UserAddressScreen());
                      },
                  ),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.shopping_bag,
                    title: "My card",
                    subtitle: "Set Shopping delivery address",
                    onTap: (){},
                  ),

                  MinhSettingsMenuTitle(
                    icon: Iconsax.bank,
                    title: "Bank Account",
                    subtitle: "Set Shopping delivery address",
                    onTap: (){},
                  ),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.discount_shape,
                    title: "My Coupons",
                    subtitle: "Set Shopping delivery address",
                    onTap: (){},
                  ),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.notification,
                    title: "Notifications",
                    subtitle: "Set Shopping delivery address",
                    onTap: (){},
                  ),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.security_card,
                    title: "Account Private",
                    subtitle: "Set Shopping delivery address",
                    onTap: (){},
                  ),

                  SizedBox(height: MinhSizes.spaceBtwSections,),

                  MinhSectionHeading(title: "App Settings", showActionButton: false,),

                  SizedBox(height: MinhSizes.spaceBtwSections,),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.document_upload,
                    title: "Load Data",
                    subtitle: "Set Shopping delivery address",
                    onTap: (){
                      Get.to(() => UploadData( ));
                    },
                  ),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.location,
                    title: "Geolocation",
                    subtitle: "Set Shopping delivery address",
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {

                      },
                    ),
                    onTap: (){},
                  ),

                  MinhSettingsMenuTitle(
                    icon: Iconsax.security_user,
                    title: "Safe Mode",
                    subtitle: "Set Shopping delivery address",
                    trailing: Switch(
                        value: false,
                        onChanged: (value) {

                        },
                    ),
                    onTap: (){},
                  ),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.image,
                    title: "HD Image Quality",
                    subtitle: "Set Shopping delivery address",
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {

                      },
                    ),
                    onTap: (){},
                  ),

                  SizedBox(height: MinhSizes.spaceBtwSections,),
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(onPressed: () async {
                        try {
                          // Lấy LogoutUseCase - tạo nếu chưa có
                          LogoutUseCase logoutUseCase;
                          try {
                            logoutUseCase = Get.find<LogoutUseCase>();
                          } catch (e) {
                            // Nếu không tìm thấy, tạo mới từ dependencies
                            try {
                              final authRepo = Get.find<AuthenticationRepository>();
                              logoutUseCase = LogoutUseCase(authRepo);
                              Get.put(logoutUseCase);
                            } catch (e2) {
                              Get.snackbar("Lỗi", "Không thể khởi tạo LogoutUseCase: ${e2.toString()}");
                              return;
                            }
                          }
                          
                          // Thực hiện logout
                          await logoutUseCase();
                          
                          // Navigate to login (logout đã clear session)
                          Get.offAll(() => LoginScreen());
                        } on Failure catch (failure) {
                          Get.snackbar("Lỗi", failure.message);
                        } catch (e) {
                          Get.snackbar("Lỗi", "Không thể đăng xuất: ${e.toString()}");
                        }
                      }, child: Text("Logout")),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwSections * 2.5,),


                ],

              ),
            ),



            
          ],
        ),
      ),
    );
  }
}


