import 'package:cuutrobaolu/common/widgets/custom_shapes/containers/MinhRoundedContainer.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class MinhCouponCode extends StatelessWidget {
  const MinhCouponCode({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    final isDark = MinhHelperFunctions.isDarkMode(context);

    return MinhRoundedContainer(
      showBorder: true,
      backgroundColor: isDark ? MinhColors.dark : MinhColors.white,
      padding: EdgeInsets.only(
        top: MinhSizes.sm,
        bottom: MinhSizes.sm,
        right: MinhSizes.sm,
        left: MinhSizes.md,
      ),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Have a promo? Enter here",
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),

          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.2),
                foregroundColor: isDark
                    ? MinhColors.white.withOpacity(0.5)
                    : MinhColors.dark.withOpacity(0.5),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Text("Apply!"),
            ),
          ),
        ],
      ),
    );
  }
}
