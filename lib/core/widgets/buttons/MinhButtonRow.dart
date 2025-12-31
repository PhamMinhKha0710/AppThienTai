import 'package:flutter/material.dart';

/// Reusable button row widget that prevents overflow
/// 
/// Use this widget when you need to display multiple buttons in a row.
/// It automatically wraps buttons in Expanded widgets to prevent overflow.
/// 
/// Example:
/// ```dart
/// MinhButtonRow(
///   primaryButton: ElevatedButton(
///     onPressed: () {},
///     child: Text('Primary'),
///   ),
///   secondaryButton: OutlinedButton(
///     onPressed: () {},
///     child: Text('Secondary'),
///   ),
/// )
/// ```
class MinhButtonRow extends StatelessWidget {
  const MinhButtonRow({
    super.key,
    this.primaryButton,
    this.secondaryButton,
    this.tertiaryButton,
    this.spacing = 12,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  /// Primary button (usually ElevatedButton)
  final Widget? primaryButton;

  /// Secondary button (usually OutlinedButton or TextButton)
  final Widget? secondaryButton;

  /// Tertiary button (optional, for cases with 3 buttons)
  final Widget? tertiaryButton;

  /// Spacing between buttons
  final double spacing;

  /// Main axis alignment
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (primaryButton != null) {
      buttons.add(
        Expanded(
          child: primaryButton!,
        ),
      );
    }

    if (secondaryButton != null) {
      if (buttons.isNotEmpty) {
        buttons.add(SizedBox(width: spacing));
      }
      buttons.add(
        Expanded(
          child: secondaryButton!,
        ),
      );
    }

    if (tertiaryButton != null) {
      if (buttons.isNotEmpty) {
        buttons.add(SizedBox(width: spacing));
      }
      buttons.add(
        Expanded(
          child: tertiaryButton!,
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: buttons,
    );
  }
}

