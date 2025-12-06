import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/widgets/images/MinhCircularImage.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:iconsax/iconsax.dart';


class MinhUserProfileTitle extends StatelessWidget {
  const MinhUserProfileTitle({
    super.key,
    this.onPressed,
  });


  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {

    final userController = Get.put(UserController());

    return Obx(
      () {

        if(userController.profileLoading.value)
        {
          return MinhShimmerEffect(width: 50, height: 15);
        }
        else
        {
          var user = userController.user.value;
          return ListTile(
            leading: MinhCircularImage(
              image: MinhImages.user,
              height: 50,
              width: 50,
              padding: 0,
            ),
            title: Text(
              // "Đinh Công Minh",
              "${user.fullName}",
              overflow: TextOverflow.ellipsis,
              style: Theme
                  .of(
                context,
              )
                  .textTheme
                  .titleLarge!
                  .apply(color: MinhColors.white),
            ),
            subtitle: Text(
              // "dinhminh4424@gmail.com",
              "${user.email}",
              overflow: TextOverflow.ellipsis,
              style: Theme
                  .of(
                context,
              )
                  .textTheme
                  .labelLarge!
                  .apply(color: MinhColors.white),
            ),
            trailing: IconButton(
              onPressed: onPressed,
              icon: Icon(Iconsax.edit, color: MinhColors.white),
            ),
          );
        }

      }
    );

  }
}
