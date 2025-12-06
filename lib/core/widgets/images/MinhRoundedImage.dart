import 'package:flutter/cupertino.dart';

import 'package:cuutrobaolu/core/constants/sizes.dart';

class MinhRoundedImage extends StatelessWidget {
  const MinhRoundedImage({
    super.key,
    this.onTap,
    required this.imageURL,
    this.width,
    this.height,
    this.applyImageRadius = true,
    this.border,
    this.backgroundColor,
    this.fix = BoxFit.contain,
    this.padding,
    this.isNetworkImage = false,
    this.borderRadius = MinhSizes.md,
  });

  final VoidCallback? onTap;
  final String imageURL;
  final double? width, height;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit? fix;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          color: backgroundColor,
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius
              ? BorderRadiusGeometry.circular(borderRadius)
              : BorderRadius.zero,
          child: Image(
            image: isNetworkImage
                ? NetworkImage(imageURL)
                : AssetImage(imageURL) as ImageProvider,
            fit: fix,

          ),
        ),
      ),
    );
  }
}