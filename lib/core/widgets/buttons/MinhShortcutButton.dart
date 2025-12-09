import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';

/// Button shortcut với icon và label, dùng cho các chức năng nhanh
class MinhShortcutButton extends StatelessWidget {
  const MinhShortcutButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.size = 40,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
      child: Container(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: size),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

