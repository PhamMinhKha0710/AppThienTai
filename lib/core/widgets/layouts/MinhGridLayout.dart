
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';

class MinhGridLayout extends StatelessWidget {
  const MinhGridLayout({
    super.key,
    required this.itemCount,
    this.mainAxisExtent = 288,
    required this.itemBuilder,
  });

  final int itemCount;
  final double? mainAxisExtent;
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MinhSizes.gridViewSpacing,
        crossAxisSpacing: MinhSizes.gridViewSpacing,
        mainAxisExtent: mainAxisExtent,


      ),
      itemBuilder: itemBuilder
    );
  }
}