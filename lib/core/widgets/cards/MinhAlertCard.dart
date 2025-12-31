import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_badge.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_card_header.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_meta_info.dart';
import 'package:cuutrobaolu/core/widgets/alerts/alert_timer.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Card hiển thị cảnh báo thiên tai
class MinhAlertCard extends StatelessWidget {
  const MinhAlertCard({
    super.key,
    this.alert,
    this.alertEntity,
    this.onTap,
    this.showActions = true,
    this.distance,
  });

  final Map<String, dynamic>? alert; // For backward compatibility
  final AlertEntity? alertEntity; // New: using entity directly
  final VoidCallback? onTap;
  final bool showActions;
  final double? distance; // Distance in km from user location

  @override
  Widget build(BuildContext context) {
    // Determine severity and color
    Color severityColor;
    String severityText;
    IconData alertIcon;
    String title;
    String content;
    String? time;
    String? location;

    if (alertEntity != null) {
      // Use entity
      severityColor = _getSeverityColor(alertEntity!.severity);
      severityText = alertEntity!.severity.viName;
      alertIcon = _getAlertTypeIcon(alertEntity!.alertType);
      title = alertEntity!.title;
      content = alertEntity!.content;
      time = _formatTime(alertEntity!.createdAt);
      location = alertEntity!.location;
    } else if (alert != null) {
      // Fallback to map format (backward compatibility)
      final isHighSeverity = alert!['severity'] == 'high' || 
                           alert!['severity'] == 'urgent' || 
                           alert!['severity'] == 'critical';
      severityColor = isHighSeverity ? Colors.red : Colors.orange;
      severityText = alert!['severity'] ?? 'medium';
      alertIcon = Iconsax.warning_2;
      title = alert!['title'] ?? 'Cảnh báo';
      content = alert!['description'] ?? '';
      time = alert!['time'];
      location = alert!['location'];
    } else {
      return const SizedBox.shrink();
    }

    // Check if expiring soon (within 24 hours)
    final isExpiringSoon = alertEntity != null &&
        alertEntity!.expiresAt != null &&
        alertEntity!.expiresAt!.difference(DateTime.now()).inHours < 24;

    // Build badges
    final severityBadge = AlertBadge(
      label: severityText,
      color: severityColor,
      variant: BadgeVariant.soft,
      size: BadgeSize.small,
    );

    final extraBadges = <AlertBadge>[];
    
    if (alertEntity != null) {
      extraBadges.add(
        AlertBadge(
          label: alertEntity!.alertType.viName,
          color: Colors.blue.shade700,
          variant: BadgeVariant.soft,
          size: BadgeSize.small,
        ),
      );
    }

    if (distance != null && distance! < 5) {
      extraBadges.add(
        AlertBadge(
          label: 'Gần bạn',
          color: Colors.green.shade700,
          variant: BadgeVariant.soft,
          size: BadgeSize.small,
        ),
      );
    }

    if (isExpiringSoon) {
      extraBadges.add(
        AlertBadge(
          label: 'Sắp hết hạn',
          color: Colors.orange.shade700,
          variant: BadgeVariant.soft,
          size: BadgeSize.small,
        ),
      );
    }

    // Build meta info items
    final metaInfoItems = <AlertMetaInfo>[];
    
    if (time != null) {
      metaInfoItems.add(
        AlertMetaInfo(
          icon: Iconsax.clock,
          text: time,
          color: Colors.grey.shade600,
        ),
      );
    }

    if (location != null) {
      metaInfoItems.add(
        AlertMetaInfo(
          icon: Iconsax.location,
          text: location,
          color: Colors.grey.shade600,
        ),
      );
    }

    if (distance != null) {
      metaInfoItems.add(
        AlertMetaInfo(
          icon: Iconsax.routing,
          text: '${distance!.toStringAsFixed(1)} km',
          color: Colors.blue.shade700,
        ),
      );
    }

    if (alertEntity != null) {
      metaInfoItems.add(
        AlertMetaInfo(
          icon: Iconsax.people,
          text: alertEntity!.targetAudience.viName,
          color: Colors.grey.shade600,
        ),
      );
    }

    // Determine elevation based on severity
    final elevation = _getElevation(alertEntity?.severity);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding based on screen size
        final isTablet = constraints.maxWidth > 600;
        final isSmall = constraints.maxWidth < 360;
        final cardPadding = isTablet
            ? MinhSizes.lg
            : isSmall
                ? MinhSizes.sm
                : MinhSizes.md;

        return Card(
          margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
          color: severityColor.withOpacity(0.05),
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
            side: BorderSide(
              color: severityColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and badges
              AlertCardHeader(
                icon: alertIcon,
                iconColor: severityColor,
                title: title,
                severityBadge: severityBadge,
                alertTypeBadge: alertEntity != null
                    ? AlertBadge(
                        label: alertEntity!.alertType.viName,
                        color: Colors.blue.shade700,
                        variant: BadgeVariant.soft,
                        size: BadgeSize.small,
                      )
                    : null,
                extraBadges: extraBadges,
              ),

              SizedBox(height: MinhSizes.spaceBtwItems),

              // Content
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (metaInfoItems.isNotEmpty) ...[
                SizedBox(height: MinhSizes.spaceBtwItems),

                // Footer with meta info
                AlertMetaInfoGrid(
                  items: metaInfoItems,
                  spacing: 16,
                  runSpacing: 8,
                ),
              ],

              // Countdown timer (if expiring soon)
              if (isExpiringSoon && alertEntity!.expiresAt != null) ...[
                SizedBox(height: MinhSizes.sm),
                AnimatedAlertTimer(
                  expiresAt: alertEntity!.expiresAt!,
                  showIcon: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  double _getElevation(AlertSeverity? severity) {
    if (severity == null) return 2;
    switch (severity) {
      case AlertSeverity.critical:
        return 4;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.low:
        return 1;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.high:
        return Colors.orange.shade700;
      case AlertSeverity.medium:
        return Colors.yellow.shade700;
      case AlertSeverity.low:
        return Colors.blue.shade700;
    }
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.disaster:
        return Iconsax.danger;
      case AlertType.weather:
        return Iconsax.cloud;
      case AlertType.evacuation:
        return Iconsax.routing;
      case AlertType.resource:
        return Iconsax.box;
      case AlertType.general:
        return Iconsax.info_circle;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

}
