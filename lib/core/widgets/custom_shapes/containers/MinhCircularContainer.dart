import 'package:flutter/material.dart';

import 'package:cuutrobaolu/core/constants/colors.dart';

class MinhCircularContainer extends StatelessWidget {

  const MinhCircularContainer(
      {
        super.key,
        this.width = 400,
        this.height = 400,
        this.bordeRadius = 400,
        this.padding = 0,
        this.child,
        this.backgroudColor = MinhColors.white,
        this.margin
      }
      );

  final double? width, height;
  final double bordeRadius;
  final double padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color? backgroudColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(bordeRadius),
          color: backgroudColor,
      ),
    );
  }


}