import 'package:flutter/material.dart';

/// Reusable title row widget that prevents overflow
/// 
/// Use this widget when you need to display a title with a trailing widget
/// (like a badge, icon, or status indicator). It automatically handles
/// text overflow and ensures the trailing widget is always visible.
/// 
/// Example:
/// ```dart
/// MinhTitleRow(
///   title: 'Task Title',
///   trailing: Container(
///     padding: EdgeInsets.all(4),
///     child: Text('Pending'),
///   ),
/// )
/// ```
class MinhTitleRow extends StatelessWidget {
  const MinhTitleRow({
    super.key,
    required this.title,
    this.trailing,
    this.maxLines = 2,
    this.titleStyle,
    this.spacing = 8,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// Title text
  final String title;

  /// Trailing widget (badge, icon, etc.)
  final Widget? trailing;

  /// Maximum number of lines for the title
  final int maxLines;

  /// Text style for the title
  final TextStyle? titleStyle;

  /// Spacing between title and trailing widget
  final double spacing;

  /// Cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: spacing),
          trailing!,
        ],
      ],
    );
  }
}

