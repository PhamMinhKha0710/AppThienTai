import 'package:cuutrobaolu/common/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/cupertino.dart';

class MinhBoxesShimmer extends StatelessWidget {
  const MinhBoxesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible( // Thay Expanded bằng Flexible
              fit: FlexFit.loose,
              child: MinhShimmerEffect(width: 150, height: 110),
            ),
            SizedBox(width: MinhSizes.spaceBtwItems),
            Flexible( // Thay Expanded bằng Flexible
              fit: FlexFit.loose,
              child: MinhShimmerEffect(width: 150, height: 110),
            ),
          ],
        ),
        SizedBox(height: MinhSizes.spaceBtwItems), // Thay width bằng height
        Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: MinhShimmerEffect(width: 150, height: 110),
            ),
            SizedBox(width: MinhSizes.spaceBtwItems),
            Flexible(
              fit: FlexFit.loose,
              child: MinhShimmerEffect(width: 150, height: 110),
            ),
          ],
        ),
        SizedBox(height: MinhSizes.spaceBtwItems), // Thay width bằng height
        Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: MinhShimmerEffect(width: 150, height: 110),
            ),
            SizedBox(width: MinhSizes.spaceBtwItems),
            Flexible(
              fit: FlexFit.loose,
              child: MinhShimmerEffect(width: 150, height: 110),
            ),
          ],
        ),
      ],
    );
  }
}