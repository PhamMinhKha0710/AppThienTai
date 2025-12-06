import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MinhFromDriver extends StatelessWidget {
  const MinhFromDriver({
    super.key,
    required this.driverText
  });

  final String driverText;

  @override
  Widget build(BuildContext context) {
    bool isDark = MinhHelperFunctions.isDarkMode(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Divider(
            color: isDark ? MinhColors.darkerGrey : MinhColors.grey,
            thickness: 0.5,
            indent: 60,
            endIndent: 5,
          ),
        ),
        Text(
          MinhTexts.orSignInWith.capitalize!,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Flexible(
          child: Divider(
            color: isDark ? MinhColors.darkerGrey : MinhColors.grey,
            thickness: 0.5,
            indent: 5,
            endIndent: 60,
          ),
        ),
      ],
    );
  }
}