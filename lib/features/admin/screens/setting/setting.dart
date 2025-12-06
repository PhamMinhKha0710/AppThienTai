import 'package:cuutrobaolu/common/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';

import 'package:cuutrobaolu/common/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/features/shop/screens/home/widgets/MinhHomeAppbar.dart';
import 'package:cuutrobaolu/features/shop/screens/home/widgets/MinhHomeCategory.dart';
import 'package:cuutrobaolu/features/shop/screens/home/widgets/MinhPromoSlider.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';

import 'package:cuutrobaolu/util/constants/sizes.dart';

import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/custom_shapes/containers/MinhSearchContainer.dart';



class SettingAdminScreen extends StatelessWidget {
  const SettingAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Primary
            MinhPrimaryHeaderContainer(
              child: Column(
                children: [
                  // Appbar
                  MinhHomeAppbar(),
                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Searh
                  MinhSearchContainer(
                    text: "ADMIN",
                    icon: Iconsax.search_normal,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Category
                  Padding(
                    padding: EdgeInsets.only(left: MinhSizes.defaultSpace),
                    child: Column(
                      children: [
                        // heading
                        MinhSectionHeading(
                          title: "ADMIN ",
                          buttonTitle: "buttonTitle",
                          textColor: MinhColors.white,
                          showActionButton: false,
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems),

                        // category
                        MinhHomeCategory(),
                        SizedBox(height: MinhSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                ],
              ),
            ),

            // Couser
            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                children: [
                  MinhPromoSlider(),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  MinhSectionHeading(
                    title: "Popular Products",
                    showActionButton: true,
                    onPressed: () {



                    },
                  ),
                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Popular Product

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
