import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MinhShimmerEffect  extends StatelessWidget {
  const MinhShimmerEffect ({
    super.key,
    required this.width,
    required this.height,
     this.radius = 15,
    this.color
  });

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: color ?? (isDark ? MinhColors.darkerGrey : MinhColors.white),
          ),
        ),
    );
  }
}
