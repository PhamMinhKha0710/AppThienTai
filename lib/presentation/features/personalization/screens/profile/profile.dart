import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/images/MinhCircularImage.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/widgets/ChangeName.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/widgets/MinhProfileMenu.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(UserController());
    var user = controller.user.value;

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Profile"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MinhSizes.defaultSpace),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Obx(
                        () {
                          final networdImage = controller.user.value.profilePicture;
                          final image = networdImage.isEmpty ? MinhImages.user : networdImage;
                          if(controller.imageLoading.value)
                          {
                            return MinhShimmerEffect(width: 80, height: 80, radius: 80,);
                          }
                          else {
                            return MinhCircularImage(
                              image: image,
                              width: 80,
                              height: 80,
                              isNetworkImage: networdImage.isNotEmpty,
                            );
                          }
                        }
                      ),
                      // SizedBox(height: MinhSizes.spaceBtwItems,),
                      TextButton(
                          onPressed: (){
                            controller.uploadUserProfilePicture();
                          },
                          child: Text("Change Profile Image"),

                      ),
                    ],
                  ),
                ),
                SizedBox(height: MinhSizes.spaceBtwItems/2,),

                Divider(color: MinhColors.darkerGrey,),
                SizedBox(height: MinhSizes.spaceBtwItems,),

                MinhSectionHeading(title: "Profile Information", showActionButton: false,),
                SizedBox(height: MinhSizes.spaceBtwItems,),

                MinhProfileMenu(title: "Name", value: user.fullName, onTap: (){
                  Get.to(() => ChangeName());
                }),
                MinhProfileMenu(title: "UserName", value: user.username, onTap: (){}),

                SizedBox(height: MinhSizes.spaceBtwItems,),

                Divider(color: MinhColors.darkerGrey,),
                SizedBox(height: MinhSizes.spaceBtwItems,),

                MinhSectionHeading(title: "Personal Information", showActionButton: false,),
                SizedBox(height: MinhSizes.spaceBtwItems,),

                MinhProfileMenu(title: "UserId", value: user.id, icon: Iconsax.copy, onTap: (){}),
                MinhProfileMenu(title: "Email", value: user.email, onTap: (){}),
                MinhProfileMenu(title: "Phone Number", value: "+84 ${user.phoneNumber}", onTap: (){}),
                MinhProfileMenu(title: "Gender", value: "Male", onTap: (){}),
                MinhProfileMenu(title: "Date of Birth", value: "4 Aril, 2004 ", onTap: (){}),

                Divider(color: MinhColors.darkerGrey,),
                SizedBox(height: MinhSizes.spaceBtwItems,),
                Center(
                  child: TextButton(
                      onPressed: (){
                        controller.deleteAccountWarningPopup();
                      },
                      child: Text("Close Account", style: TextStyle(color: Colors.red),),
                  ),
                ),
                SizedBox(height: MinhSizes.spaceBtwItems,),





              ],

          ),
        ),
      ),
    );
  }
}

