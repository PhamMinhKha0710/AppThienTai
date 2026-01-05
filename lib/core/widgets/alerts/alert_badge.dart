import 'package:flutter/material.dart';

/// Reusable badge widget for alerts
/// 
/// Supports different badge types: severity, alert type, status, etc.
/// Automatically handles text overflow and provides consistent styling.
class AlertBadge extends StatelessWidget {
  const AlertBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.size = BadgeSize.medium,
    this.variant = BadgeVariant.filled,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final BadgeSize size;
  final BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final borderRadius = _getBorderRadius();

    Widget content = Text(
      label,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          const SizedBox(width: 4),
          Flexible(child: content),
        ],
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: borderRadius,
        border: variant == BadgeVariant.outlined
            ? Border.all(color: color, width: 1)
            : null,
      ),
      child: content,
    );
  }

  TextStyle _getTextStyle() {
    final fontSize = size == BadgeSize.small ? 10.0 : 11.0;
    final fontWeight = FontWeight.w600;
    return TextStyle(
      fontSize: fontSize,
      color: _getTextColor(),
      fontWeight: fontWeight,
    );
  }

  Color _getTextColor() {
    switch (variant) {
      case BadgeVariant.filled:
        return Colors.white;
      case BadgeVariant.outlined:
      case BadgeVariant.soft:
        return color;
    }
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case BadgeVariant.filled:
        return color;
      case BadgeVariant.outlined:
        return Colors.transparent;
      case BadgeVariant.soft:
        return color.withOpacity(0.1);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    }
  }

  BorderRadius _getBorderRadius() {
    final radius = size == BadgeSize.small ? 4.0 : 6.0;
    return BorderRadius.circular(radius);
  }

  double _getIconSize() {
    switch (size) {
      case BadgeSize.small:
        return 10.0;
      case BadgeSize.medium:
        return 12.0;
      case BadgeSize.large:
        return 14.0;
    }
  }
}

enum BadgeSize {
  small,
  medium,
  large,
}

enum BadgeVariant {
  filled,
  outlined,
  soft,
}


















