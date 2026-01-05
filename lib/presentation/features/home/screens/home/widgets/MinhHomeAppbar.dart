import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/widgets/products/card/MinhCounterIcon.dart';
import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/constants/text_strings.dart';
import '../../../../personalization/controllers/user/user_controller.dart';


class MinhHomeAppbar extends StatelessWidget {
  const MinhHomeAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(UserController());

    return MinhAppbar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị title khác nhau theo user type
          Obx(() {
            final userType = controller.user.value.userType;
            String title = MinhTexts.homeAppbarTitle;
            if (userType.enName.toLowerCase() == 'volunteer') {
              title = "Tình nguyện viên";
            } else if (userType.enName.toLowerCase() == 'admin') {
              title = "Quản trị viên";
            } else {
              title = MinhTexts.homeAppbarTitle;
            }
            return Text(
              title,
              style: Theme.of(context).textTheme.labelMedium!.apply(color: MinhColors.grey),
            );
          }),
          SizedBox(height: MinhSizes.spaceBtwItems,),
          Obx(
            () {
              if(controller.profileLoading.value)
              {
                return MinhShimmerEffect(
                    width: 80,
                    height: 15
                );
              }
              else
              {
                // Hiển thị thông tin khác nhau theo user type
                final userType = controller.user.value.userType;
                String subtitle = controller.user.value.fullName;
                if (userType.enName.toLowerCase() == 'volunteer') {
                  subtitle = "${controller.user.value.fullName}\nTrạng thái: ${controller.user.value.volunteerStatus.viName}";
                } else if (userType.enName.toLowerCase() == 'admin') {
                  subtitle = "${controller.user.value.fullName}\nQuản trị hệ thống";
                }
                return Text(
                  subtitle,
                  style: Theme.of(context).textTheme.headlineSmall!.apply(color: MinhColors.white),
                );
              }
            }
          ),
        ],
      ),
      action: [
        MinhCounterIcon(
          onPressed: (){

          },
          colorIcon: MinhColors.white,
        ),


      ],
    );

  }
}
