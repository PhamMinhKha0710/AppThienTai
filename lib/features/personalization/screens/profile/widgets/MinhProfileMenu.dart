import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MinhProfileMenu extends StatelessWidget {
  const MinhProfileMenu({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
    this.icon = Iconsax.arrow_right_34,
  });

  final String title, value;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: MinhSizes.spaceBtwItems/10),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
              Expanded(
                  flex: 5,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),

              ),
              Expanded(
                  child: IconButton(
                      onPressed: (){},
                      icon: Icon(
                        icon,
                        size: 18,
                      ),
                  ),
              ),
            ],
          ),
      ),
    );
  }
}
