import 'package:cuutrobaolu/common/widgets/custom_shapes/containers/MinhCircularContainer.dart';
import 'package:cuutrobaolu/common/widgets/images/MinhRoundedImage.dart';
import 'package:cuutrobaolu/common/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/features/shop/controllers/banner_controller.dart';
import 'package:cuutrobaolu/features/shop/controllers/home_controller.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MinhPromoSlider extends StatelessWidget {
  const MinhPromoSlider({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final controllerBanner = Get.put(BannerController());

    return Obx(
      () {
        if(controllerBanner.isLoading.value)
        {
          return MinhShimmerEffect(width: double.infinity, height: 190);
        }

        if(controllerBanner.allBanner.isEmpty)
        {
          return Center(child: Text("No Data Found!"));
        }
        else{
          return Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                  onPageChanged: (index, reason) {
                    controllerBanner.updatePageIndicator(index);
                  },
                ),
                items: controllerBanner.allBanner.map(
                      (element){
                    return MinhRoundedImage(
                      imageURL:element.imageUrl,
                      isNetworkImage: true,
                      onTap: () => Get.toNamed(element.targetScreen),
                    );
                  },
                ).toList(),

              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              Obx(
                    () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < controllerBanner.allBanner.length; i++) ...[
                      MinhCircularContainer(
                        height: 4,
                        width: (controllerBanner.carousalCurrentIndex == i ? 25 : 4),
                        margin: EdgeInsets.only(right: 10),
                        backgroudColor: (controllerBanner.carousalCurrentIndex == i
                            ? MinhColors.primary
                            : MinhColors.grey
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }


      },
    );
  }
}
