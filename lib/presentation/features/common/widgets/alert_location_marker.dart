import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/widgets/alert_detail_widgets.dart';
import 'package:flutter/material.dart';

/// Custom marker widget for alert location on map
class AlertLocationMarker extends StatelessWidget {
  final AlertEntity alert;

  const AlertLocationMarker({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final color = AlertSeverityHelper.getColor(alert.severity);
    final icon = AlertTypeHelper.getIcon(alert.alertType);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

