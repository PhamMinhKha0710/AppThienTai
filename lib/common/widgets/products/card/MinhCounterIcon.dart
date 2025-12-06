import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MinhCounterIcon extends StatelessWidget {
  const MinhCounterIcon({
    super.key,
    required this.colorIcon,
    required this.onPressed,
  });

  final Color colorIcon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          child: Container(
            height: 19,
            width: 19,
            decoration: BoxDecoration(
              color: MinhColors.dark,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                "9",
                style: Theme.of(context)
                    .textTheme.labelLarge!
                    .apply(
                    color: MinhColors.white,
                    fontSizeFactor: 0.8
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            Iconsax.shopping_bag,
            color: colorIcon,),
        ),
      ],
    );
  }
}