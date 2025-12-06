import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';

import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/widgets/shimmers/MinhVerticalProductShimmer.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/home/widgets/MinhHomeAppbar.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/home/widgets/MinhHomeCategory.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/home/widgets/MinhPromoSlider.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/widgets/custom_shapes/containers/MinhSearchContainer.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    text: "Search in Store",
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
                          title: "Popular Categories",
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

