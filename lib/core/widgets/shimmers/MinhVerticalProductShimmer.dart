import 'package:cuutrobaolu/core/widgets/layouts/MinhGridLayout.dart';
import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/cupertino.dart';

class MinhVerticalProductShimmer extends StatelessWidget {
  const MinhVerticalProductShimmer({
    super.key,
    this.itemCount = 4,
  });

  final int itemCount ;

  @override
  Widget build(BuildContext context) {
    return MinhGridLayout(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                MinhShimmerEffect(width: 180, height: 180),
                SizedBox(height: MinhSizes.spaceBtwItems,),

                // Text
                MinhShimmerEffect(width: 160, height: 15),
                SizedBox(height: MinhSizes.spaceBtwItems / 2,),
                MinhShimmerEffect(width: 110, height: 15),

              ],

            ),
          );
        },
    );
  }
}
