import 'package:cuutrobaolu/common/widgets/texts/MinhBrandTitleText.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/enums.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';

class MinhBrandTitleWithVerifiedIcon extends StatelessWidget {
  const MinhBrandTitleWithVerifiedIcon({
    super.key,
    required this.title,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
    this.color,
    this.brandTextSize = TextSizes.small,
    this.iconColor = MinhColors.primary,
  });

  final String title;
  final TextAlign? textAlign;
  final int maxLines;
  final Color? color;
  final Color? iconColor;

  final TextSizes brandTextSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: MinhBrandTitleText(
            title: title,
            color: color,
            maxLines: maxLines,
            textAlign: textAlign,
            brandTextSize: brandTextSize,

          ),
        ),
        SizedBox(width: MinhSizes.xs,),
        Icon(
          Iconsax.verify5,
          size: MinhSizes.iconXs,
          color: iconColor,
        ),
      ],
    );
  }
}