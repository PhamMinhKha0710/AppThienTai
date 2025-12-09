import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';

/// Tab button widget dùng chung cho các màn hình có tabs
class MinhTabButton extends StatelessWidget {
  const MinhTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MinhSizes.defaultSpace),
        decoration: BoxDecoration(
          color: isDark ? MinhColors.darkerGrey : MinhColors.light,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? MinhColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.apply(
            color: isSelected ? MinhColors.primary : null,
          ),
        ),
      ),
    );
  }
}

/// Container cho tabs với background và border
class MinhTabContainer extends StatelessWidget {
  const MinhTabContainer({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? MinhColors.darkerGrey : MinhColors.light,
        border: Border(
          bottom: BorderSide(
            color: isDark ? MinhColors.darkGrey : MinhColors.grey,
          ),
        ),
      ),
      child: Row(children: children),
    );
  }
}


