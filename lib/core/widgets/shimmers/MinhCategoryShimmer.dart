import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';

class MinhCategoryShimmer extends StatelessWidget {
  const MinhCategoryShimmer({
    super.key,
    this.itemCount = 6
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
          shrinkWrap: true,
          itemCount: itemCount,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => SizedBox(width: MinhSizes.spaceBtwItems,),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                MinhShimmerEffect(width: 55, height: 55, radius: 55,),
                SizedBox(height: MinhSizes.spaceBtwItems / 2,),

                // Text
                MinhShimmerEffect(width: 55, height: 8, ),
              ],
            );
          },

      ),
    );
  }
}
