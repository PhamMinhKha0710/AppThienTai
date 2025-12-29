import 'package:cuutrobaolu/core/constants/sizes.dart';
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

    return Card(
      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      color: severityColor.withOpacity(0.05),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
        side: BorderSide(
          color: severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
        child: Padding(
          padding: EdgeInsets.all(MinhSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert icon
                  Container(
                    padding: EdgeInsets.all(MinhSizes.sm),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
                    ),
                    child: Icon(
                      alertIcon,
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
                            // Severity badge
                            _buildBadge(
                              severityText,
                              severityColor,
                            ),
                            
                            // Alert type badge (if entity)
                            if (alertEntity != null)
                              _buildBadge(
                                alertEntity!.alertType.viName,
                                Colors.blue.shade700,
                              ),
                            
                            // Near you badge
                            if (distance != null && distance! < 5)
                              _buildBadge(
                                'Gần bạn',
                                Colors.green.shade700,
                              ),
                            
                            // Expiring soon badge
                            if (isExpiringSoon)
                              _buildBadge(
                                'Sắp hết hạn',
                                Colors.orange.shade700,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow icon
                  Icon(
                    Iconsax.arrow_right_3,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              
              SizedBox(height: MinhSizes.spaceBtwItems),
              
              // Content
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: MinhSizes.spaceBtwItems),
              
              // Footer with meta info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  // Time
                  if (time != null)
                    _buildMetaInfo(
                      Iconsax.clock,
                      time,
                      Colors.grey,
                    ),
                  
                  // Location
                  if (location != null)
                    _buildMetaInfo(
                      Iconsax.location,
                      location,
                      Colors.grey,
                    ),
                  
                  // Distance
                  if (distance != null)
                    _buildMetaInfo(
                      Iconsax.routing,
                      '${distance!.toStringAsFixed(1)} km',
                      Colors.blue,
                    ),
                  
                  // Target audience (if entity)
                  if (alertEntity != null)
                    _buildMetaInfo(
                      Iconsax.people,
                      alertEntity!.targetAudience.viName,
                      Colors.grey,
                    ),
                ],
              ),
              
              // Countdown timer (if expiring soon)
              if (isExpiringSoon && alertEntity!.expiresAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.timer,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hết hạn sau ${_getTimeRemaining(alertEntity!.expiresAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
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

  String _getTimeRemaining(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining.inHours < 1) {
      return '${remaining.inMinutes} phút';
    } else if (remaining.inDays < 1) {
      return '${remaining.inHours} giờ';
    } else {
      return '${remaining.inDays} ngày';
    }
  }
}
