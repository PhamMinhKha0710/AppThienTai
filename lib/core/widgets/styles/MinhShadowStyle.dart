import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:flutter/cupertino.dart';

class MinhShadowStyle{

  static final verticalProductShadow = BoxShadow(
    color: MinhColors.darkerGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: Offset(0, 2),
  );

  static final horizontalProductShadow = BoxShadow(
    color: MinhColors.darkerGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: Offset(0, 2),
  );

}