import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../util/constants/colors.dart';
import '../../../../../util/constants/text_strings.dart';

class LoginDriver extends StatelessWidget {
  const LoginDriver({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
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