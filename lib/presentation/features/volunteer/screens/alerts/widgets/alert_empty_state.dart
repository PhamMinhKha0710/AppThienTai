import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Empty state widget for volunteer alerts screen
class VolunteerAlertEmptyState extends StatelessWidget {
  const VolunteerAlertEmptyState({
    super.key,
    required this.message,
    this.icon = Iconsax.info_circle,
    this.onRefresh,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              SizedBox(height: MinhSizes.spaceBtwItems),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Làm mới'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

