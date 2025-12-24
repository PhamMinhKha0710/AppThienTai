
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhUserProfileTitle.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/domain/usecases/logout_usecase.dart';
import 'package:cuutrobaolu/domain/repositories/authentication_repository.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_profile_controller.dart';
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
    // Initialize controller once
    final victimProfileController = Get.put(VictimProfileController(), permanent: false);
    // final userController = Get.put(UserController(), permanent: true); // Thêm dòng này
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
                  // My Requests Section
                  MinhSectionHeading(
                    title: "Yêu cầu của tôi",
                    showActionButton: false,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  Obx(() {
                    final controller = victimProfileController;
                    
                    if (controller.isLoading.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(MinhSizes.defaultSpace),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.myRequests.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(MinhSizes.defaultSpace),
                        child: Text(
                          "Chưa có yêu cầu nào",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.myRequests.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: MinhSizes.spaceBtwItems / 2),
                      itemBuilder: (context, index) {
                        final request = controller.myRequests[index];
                        final statusColor = controller.getStatusColor(request['status']);
                        final severityColor = controller.getSeverityColor(request['severity']);

                        return Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(MinhSizes.md),
                            leading: Container(
                              padding: EdgeInsets.all(MinhSizes.sm),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
                              ),
                              child: Icon(
                                Iconsax.document_text,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              request['title'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  request['description'] ?? '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MinhSizes.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        request['statusVi'] ?? '',
                                        style: Theme.of(context).textTheme.bodySmall?.apply(
                                              color: statusColor,
                                              fontSizeFactor: 0.9,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: MinhSizes.spaceBtwItems / 2),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MinhSizes.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: severityColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        request['severityVi'] ?? '',
                                        style: Theme.of(context).textTheme.bodySmall?.apply(
                                              color: severityColor,
                                              fontSizeFactor: 0.9,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${request['timeStr']} • ${request['address'] ?? ''}',
                                  style: Theme.of(context).textTheme.bodySmall?.apply(
                                        color: MinhColors.darkerGrey,
                                      ),
                                ),
                              ],
                            ),
                            trailing: Icon(Iconsax.arrow_right_3),
                          ),
                        );
                      },
                    );
                  }),

                  SizedBox(height: MinhSizes.spaceBtwSections),

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


