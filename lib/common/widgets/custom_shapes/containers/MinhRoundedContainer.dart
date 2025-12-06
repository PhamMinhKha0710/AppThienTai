import 'package:flutter/cupertino.dart';

import '../../../../util/constants/colors.dart';
import '../../../../util/constants/sizes.dart';

class MinhRoundedContainer extends StatelessWidget {
  const MinhRoundedContainer(
      {super.key,
        this.width,
        this.height,
        this.radius = MinhSizes.borderRadiusLg,
        this.padding,
        this.margin,
        this.backgroundColor = MinhColors.white,
        this.borderColor = MinhColors.borderPrimary,
        this.showBorder = false,
        this.child
      });

  final double? width, height;
  final double radius;
  final EdgeInsetsGeometry? padding, margin;
  final Color backgroundColor, borderColor;
  final bool showBorder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBorder ? Border.all(color: borderColor) : null,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
