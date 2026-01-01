import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Section Title Widget
class AlertSectionTitle extends StatelessWidget {
  final String title;

  const AlertSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Info Card Widget
class AlertInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const AlertInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _IconContainer(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: _ContentColumn(title: title, content: content),
          ),
        ],
      ),
    );
  }
}

/// Icon Container for Info Card
class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconContainer({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

/// Content Column for Info Card
class _ContentColumn extends StatelessWidget {
  final String title;
  final String content;

  const _ContentColumn({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Expandable Section Widget
class AlertExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final Color color;

  const AlertExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ExpansionTile(
          leading: _LeadingIcon(icon: icon, color: color),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Iconsax.arrow_right_3,
            color: Colors.grey.shade600,
            size: 20,
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          children: [
            _ExpandedContent(content: content, color: color),
          ],
        ),
      ),
    );
  }
}

/// Leading Icon for Expandable Section
class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _LeadingIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

/// Expanded Content for Expandable Section
class _ExpandedContent extends StatelessWidget {
  final String content;
  final Color color;

  const _ExpandedContent({
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }
}

/// Helper class for Alert Severity
class AlertSeverityHelper {
  const AlertSeverityHelper._();

  static Color getColor(AlertSeverity severity) {
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
}

/// Helper class for Alert Type
class AlertTypeHelper {
  const AlertTypeHelper._();

  static IconData getIcon(AlertType type) {
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
}

/// Helper class for DateTime formatting
class AlertDateTimeHelper {
  const AlertDateTimeHelper._();

  static String format(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return format(dateTime);
  }
}







