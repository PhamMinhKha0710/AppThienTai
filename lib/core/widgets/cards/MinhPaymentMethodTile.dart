import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Tile hiển thị phương thức thanh toán có thể chọn
class MinhPaymentMethodTile extends StatelessWidget {
  const MinhPaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? MinhColors.primary : MinhColors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? MinhColors.primary : null),
            SizedBox(width: MinhSizes.spaceBtwItems),
            Expanded(child: Text(title)),
            if (isSelected)
              Icon(Iconsax.tick_circle, color: MinhColors.primary),
          ],
        ),
      ),
    );
  }
}






