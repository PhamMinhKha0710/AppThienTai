import 'package:flutter/material.dart';

/// Reusable meta info widget for alerts
/// 
/// Displays icon + text information (time, location, distance, etc.)
/// with consistent layout and spacing.
class AlertMetaInfo extends StatelessWidget {
  const AlertMetaInfo({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.iconSize = 14.0,
    this.textSize = 12.0,
    this.spacing = 4.0,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final double iconSize;
  final double textSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final infoColor = color ?? Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: infoColor,
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: infoColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Grid layout for multiple meta info items
class AlertMetaInfoGrid extends StatelessWidget {
  const AlertMetaInfoGrid({
    super.key,
    required this.items,
    this.spacing = 16.0,
    this.runSpacing = 8.0,
    this.crossAxisCount = 2,
  });

  final List<AlertMetaInfo> items;
  final double spacing;
  final double runSpacing;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items,
    );
  }
}

