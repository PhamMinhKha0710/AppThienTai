import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_badge.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Header section for alert cards
/// 
/// Displays icon, title, and badges in a consistent layout.
/// Prevents overflow by using Expanded for title and Wrap for badges.
class AlertCardHeader extends StatelessWidget {
  const AlertCardHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.severityBadge,
    this.alertTypeBadge,
    this.extraBadges = const [],
    this.showArrow = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final AlertBadge severityBadge;
  final AlertBadge? alertTypeBadge;
  final List<AlertBadge> extraBadges;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alert icon
        Container(
          padding: EdgeInsets.all(MinhSizes.sm),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: MinhSizes.spaceBtwItems),

        // Title and badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: MinhSizes.xs),

              // Badges row
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  severityBadge,
                  if (alertTypeBadge != null) alertTypeBadge!,
                  ...extraBadges,
                ],
              ),
            ],
          ),
        ),

        // Arrow icon
        if (showArrow)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Iconsax.arrow_right_3,
              color: Colors.grey,
              size: 20,
            ),
          ),
      ],
    );
  }
}





















