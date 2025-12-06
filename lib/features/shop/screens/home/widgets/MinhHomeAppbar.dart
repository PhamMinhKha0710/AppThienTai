import 'package:cuutrobaolu/common/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/common/widgets/appbar/MinhAppbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/products/card/MinhCounterIcon.dart';
import '../../../../../util/constants/colors.dart';
import '../../../../../util/constants/sizes.dart';
import '../../../../../util/constants/text_strings.dart';
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
          Text(
            MinhTexts.homeAppbarTitle,
            style: Theme.of(context).textTheme.labelMedium!.apply(color: MinhColors.grey),
          ),
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
                return Text(
                  // MinhTexts.homeAppbarSubTitle,
                  controller.user.value.fullName,
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