import 'package:cuutrobaolu/common/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/common/widgets/images/MinhRoundedImage.dart';
import 'package:cuutrobaolu/common/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/features/personalization/screens/settings/upload_data/UpLoadBanner.dart';
import 'package:cuutrobaolu/features/shop/controllers/banner_controller.dart';

import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

class UploadData extends StatelessWidget {
  const UploadData({super.key});

  @override
  Widget build(BuildContext context) {

    final uploadBanner = Get.put(BannerController());


    return Scaffold(
      appBar: MinhAppbar(
        title: Text("UpLoad Data"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          children: [
            MinhSectionHeading(
                title: "Main Record",
                showActionButton: false,
            ),
            SizedBox(height: MinhSizes.spaceBtwSections,),

            // Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                        Iconsax.shop,
                        color: MinhColors.primary,
                    ),
                    SizedBox(
                      width: MinhSizes.sm,
                    ),
                    Text(
                        "Upload Banners",
                        style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                    onPressed: (){
                      Get.dialog(
                        AlertDialog(
                          title: Text("Lựa Chọn Option Banners"),
                          content: Padding(
                            padding: const EdgeInsets.all(MinhSizes.sm),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // ✨ dialog chỉ fit nội dung
                              children: [
                                Flexible(
                                    child: Container(
                                        child: MinhRoundedImage(imageURL: MinhImages.bannerLuffy_1),
                                        height: MinhSizes.productImageSize,
                                    ),
                                ),

                                SizedBox(height: MinhSizes.spaceBtwSections,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Get.back();
                                          Get.back();

                                        },
                                        child: Text("Cancel"),
                                      ),
                                    ),
                                    SizedBox(width: MinhSizes.sm,),
                                    Flexible(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Get.back();
                                          Get.to(() => UploadBanner());

                                        },
                                        child: Text("Form"),
                                      ),
                                    ),
                                    SizedBox(width: MinhSizes.sm,),
                                    Flexible(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          uploadBanner.uploadBannerFromAsset();
                                        },
                                        child: Text("Asset"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, 
                    icon: Icon(
                        Iconsax.arrow_up4,
                        color: MinhColors.primary,
                    ),
                    
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwSections,),

            // Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.chart_square,
                      color: MinhColors.primary,
                    ),
                    SizedBox(
                      width: MinhSizes.sm,
                    ),
                    Text(
                      "Upload Category",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: (){
                    Get.dialog(
                      AlertDialog(
                        title: Text("Lựa Chọn Option Category"),
                        content: Padding(
                          padding: const EdgeInsets.all(MinhSizes.sm),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Flexible(
                                child: Container(
                                  child: MinhRoundedImage(imageURL: MinhImages.bannerLuffy_2),
                                  height: MinhSizes.productImageSize,
                                ),
                              ),
                              SizedBox(height: MinhSizes.spaceBtwSections,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Get.back();
                                        Get.back();

                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ),
                                  SizedBox(width: MinhSizes.sm,),
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Get.back();
                                        Get.to(() => UploadBanner());

                                      },
                                      child: Text("Form"),
                                    ),
                                  ),
                                  SizedBox(width: MinhSizes.sm,),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Iconsax.arrow_up4,
                    color: MinhColors.primary,
                  ),

                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwSections,),

            // Product
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.ship,
                      color: MinhColors.primary,
                    ),
                    SizedBox(
                      width: MinhSizes.sm,
                    ),
                    Text(
                      "Upload Product",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: (){
                    Get.dialog(
                      AlertDialog(
                        title: Text("Lựa Chọn Option Product"),
                        content: Padding(
                          padding: const EdgeInsets.all(MinhSizes.sm),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Flexible(
                                child: Container(
                                  child: MinhRoundedImage(imageURL: MinhImages.bannerLuffy_3),
                                  height: MinhSizes.productImageSize,
                                ),
                              ),
                              SizedBox(height: MinhSizes.spaceBtwSections,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Get.back();
                                        Get.back();

                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ),
                                  SizedBox(width: MinhSizes.sm,),
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Get.back();
                                        Get.to(() => UploadBanner());

                                      },
                                      child: Text("Form"),
                                    ),
                                  ),
                                  SizedBox(width: MinhSizes.sm,),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Iconsax.arrow_up4,
                    color: MinhColors.primary,
                  ),

                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwSections,),

            // Brand
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.buildings,
                      color: MinhColors.primary,
                    ),
                    SizedBox(
                      width: MinhSizes.sm,
                    ),
                    Text(
                      "Upload Brand",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: (){
                    Get.dialog(
                      AlertDialog(
                        title: Text("Lựa Chọn Option Brand"),
                        content: Padding(
                          padding: const EdgeInsets.all(MinhSizes.sm),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Flexible(
                                child: Container(
                                  child: MinhRoundedImage(imageURL: MinhImages.bannerLuffy_4),
                                  height: MinhSizes.productImageSize,
                                ),
                              ),
                              SizedBox(height: MinhSizes.spaceBtwSections,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Get.back();
                                        Get.back();

                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ),
                                  SizedBox(width: MinhSizes.sm,),
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Get.back();
                                        Get.to(() => UploadBanner());

                                      },
                                      child: Text("Form"),
                                    ),
                                  ),
                                  SizedBox(width: MinhSizes.sm,),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Iconsax.arrow_up4,
                    color: MinhColors.primary,
                  ),

                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwSections,),
          ],
        ),

      ),
    );
  }
}
