import 'package:cuutrobaolu/core/services/emergency_sound_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/alert_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// EmergencyAlertDialog - Full screen emergency alert overlay
class EmergencyAlertDialog extends StatefulWidget {
  final AlertEntity alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewDetails;

  const EmergencyAlertDialog({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onViewDetails,
  });

  /// Show emergency alert dialog
  static Future<void> show(AlertEntity alert) async {
    // Trigger emergency sound and vibration
    try {
      final soundService = Get.find<EmergencySoundService>();
      await soundService.triggerEmergencyAlert();
    } catch (e) {
      debugPrint('EmergencySoundService not available: $e');
    }

    await Get.dialog(
      EmergencyAlertDialog(alert: alert),
      barrierDismissible: false,
      barrierColor: Colors.black87,
    );
  }

  @override
  State<EmergencyAlertDialog> createState() => _EmergencyAlertDialogState();
}

class _EmergencyAlertDialogState extends State<EmergencyAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _stopAlert() {
    try {
      final soundService = Get.find<EmergencySoundService>();
      soundService.stopAllAlerts();
    } catch (e) {
      debugPrint('EmergencySoundService not available: $e');
    }
  }

  void _handleDismiss() {
    _stopAlert();
    Get.back();
    widget.onDismiss?.call();
  }

  void _handleViewDetails() {
    _stopAlert();
    Get.back();
    Get.to(() => AlertDetailScreen(alert: widget.alert));
    widget.onViewDetails?.call();
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(widget.alert.severity);

    return WillPopScope(
      onWillPop: () async {
        _handleDismiss();
        return false;
      },
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                severityColor.withOpacity(0.95),
                severityColor.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated alert icon
                _AnimatedAlertIcon(
                  pulseAnimation: _pulseAnimation,
                  fadeAnimation: _fadeAnimation,
                  alertType: widget.alert.alertType,
                ),
                const SizedBox(height: 32),

                // Severity badge
                _SeverityBadge(severity: widget.alert.severity),
                const SizedBox(height: 24),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.alert.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Content preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.alert.content.length > 150
                        ? '${widget.alert.content.substring(0, 150)}...'
                        : widget.alert.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Location if available
                if (widget.alert.location != null)
                  _LocationInfo(location: widget.alert.location!),

                const SizedBox(height: 48),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // View safety guide button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _handleViewDetails,
                          icon: const Icon(Iconsax.shield_tick, size: 24),
                          label: const Text(
                            'Xem hướng dẫn an toàn',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: severityColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dismiss button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _handleDismiss,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Đã hiểu',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return const Color(0xFFB71C1C); // Dark red
      case AlertSeverity.high:
        return const Color(0xFFE65100); // Dark orange
      case AlertSeverity.medium:
        return const Color(0xFFF57F17); // Dark yellow
      case AlertSeverity.low:
        return const Color(0xFF1565C0); // Dark blue
    }
  }
}

/// Animated alert icon widget
class _AnimatedAlertIcon extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Animation<double> fadeAnimation;
  final AlertType alertType;

  const _AnimatedAlertIcon({
    required this.pulseAnimation,
    required this.fadeAnimation,
    required this.alertType,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(alertType),
                    size: 48,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(AlertType type) {
    switch (type) {
      case AlertType.disaster:
        return Iconsax.danger;
      case AlertType.weather:
        return Iconsax.cloud_lightning;
      case AlertType.evacuation:
        return Iconsax.routing;
      case AlertType.resource:
        return Iconsax.box;
      case AlertType.general:
        return Iconsax.warning_2;
    }
  }
}

/// Severity badge widget
class _SeverityBadge extends StatelessWidget {
  final AlertSeverity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            severity.viName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Location info widget
class _LocationInfo extends StatelessWidget {
  final String location;

  const _LocationInfo({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.location, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              location,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

