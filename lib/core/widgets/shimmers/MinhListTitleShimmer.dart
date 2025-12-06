import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/cupertino.dart';

class MinhListTitleShimmer extends StatelessWidget {
  const MinhListTitleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MinhShimmerEffect(width: 50, height: 50, radius: 50,),
        SizedBox(width: MinhSizes.spaceBtwItems,),
        Column(
          children: [
            MinhShimmerEffect(width: 100, height: 15),
            SizedBox(height: MinhSizes.spaceBtwItems,),
            MinhShimmerEffect(width: 80, height: 12),

          ],
        ),
      ],
    );
  }
}
