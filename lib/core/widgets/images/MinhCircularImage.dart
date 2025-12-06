import 'package:cuutrobaolu/core/widgets/shimmers/MinhShimmerEffect.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:cuutrobaolu/core/constants/sizes.dart';

class MinhCircularImage extends StatelessWidget {
  const MinhCircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    this.padding = MinhSizes.sm,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.backgroundColor,
    required this.image,
    this.isNetworkImage = false,
  });

  final double width, height, padding ;
  final BoxFit? fit;
  final Color? overlayColor;
  final Color? backgroundColor;
  final String image;
  final bool isNetworkImage;



  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? ( isDark ? MinhColors.black : MinhColors.white ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: isNetworkImage
                        ? CachedNetworkImage(
                            imageUrl: image,
                            fit: fit,
                            color: overlayColor,
                            progressIndicatorBuilder: (context, url, progress) {
                              return MinhShimmerEffect(width: 55, height: 55);
                            },
                            errorWidget: (context, url, error) {
                              return Icon(Icons.error);
                            },
        
                        )
                        : Image(
                          image: AssetImage(image) as ImageProvider,
                          fit: fit,
                          color: overlayColor,
                        ),
        ),
      ),
    );
  }
}