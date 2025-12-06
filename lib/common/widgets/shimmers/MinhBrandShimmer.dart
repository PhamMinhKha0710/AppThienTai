import 'package:cuutrobaolu/common/widgets/layouts/MinhGridLayout.dart';
import 'package:cuutrobaolu/common/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:flutter/material.dart';

class MinhBrandShimmer extends StatelessWidget {
  const MinhBrandShimmer({
    super.key,
    this.itemCount = 4
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return MinhGridLayout(
        itemCount: itemCount,
        itemBuilder: (context, index) =>  MinhShimmerEffect(
            width: 300,
            height: 80
        ),
    );
  }
}
