import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

class AlertTimer extends StatelessWidget {
  const AlertTimer({
    super.key,
    required this.expiresAt,
    this.showIcon = true,
    this.animate = false,
  });

  final DateTime expiresAt;
  final bool showIcon;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
    final timeText = _formatTimeRemaining(remaining);

    return Row(
      children: [
        if (showIcon)
          Icon(
            Iconsax.timer,
            size: 14,
            color: Colors.orange.shade700,
          ),
        if (showIcon) const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Háº¿t háº¡n sau $timeText',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTimeRemaining(Duration remaining) {
    if (remaining.inHours < 1) {
      return '${remaining.inMinutes} phÃºt';
    } else if (remaining.inDays < 1) {
      return '${remaining.inHours} giá»';
    } else {
      return '${remaining.inDays} ngÃ y';
    }
  }
}

class AnimatedAlertTimer extends StatefulWidget {
  const AnimatedAlertTimer({
    super.key,
    required this.expiresAt,
    this.showIcon = true,
  });

  final DateTime expiresAt;
  final bool showIcon;

  @override
  State<AnimatedAlertTimer> createState() => _AnimatedAlertTimerState();
}

class _AnimatedAlertTimerState extends State<AnimatedAlertTimer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    final remaining = widget.expiresAt.difference(DateTime.now());
    final isUrgent = remaining.inHours < 1;

    if (isUrgent) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.expiresAt.difference(DateTime.now());
    final isUrgent = remaining.inHours < 1;

    Widget timer = AlertTimer(
      expiresAt: widget.expiresAt,
      showIcon: widget.showIcon,
    );

    if (isUrgent && _controller != null && _controller!.isAnimating) {
      timer = AnimatedBuilder(
        animation: _animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation!.value,
            child: Opacity(
              opacity: 0.7 + (_animation!.value - 0.8) * 1.5,
              child: timer,
            ),
          );
        },
      );
    }

    return timer;
  }
}
