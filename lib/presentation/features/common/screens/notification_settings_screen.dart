import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/data/services/geofencing_service.dart';
import 'package:cuutrobaolu/data/services/notification_service.dart';
import 'package:cuutrobaolu/domain/entities/notification_settings_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

/// NotificationSettingsScreen - UI for managing notification preferences
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General notifications section
            _SectionHeader(
              title: 'Thông báo chung',
              icon: Iconsax.notification,
            ),
            const SizedBox(height: 12),
            Obx(() => _SettingsTile(
                  title: 'Âm thanh cảnh báo khẩn cấp',
                  subtitle: 'Phát âm thanh khi có cảnh báo mức critical hoặc high',
                  icon: Iconsax.volume_high,
                  value: controller.settings.value.enableCriticalSound,
                  onChanged: (value) => controller.updateSetting(
                    enableCriticalSound: value,
                  ),
                )),
            Obx(() => _SettingsTile(
                  title: 'Rung',
                  subtitle: 'Rung khi có thông báo mới',
                  icon: Iconsax.mobile,
                  value: controller.settings.value.enableVibration,
                  onChanged: (value) => controller.updateSetting(
                    enableVibration: value,
                  ),
                )),
            const SizedBox(height: 24),

            // Geofencing section
            _SectionHeader(
              title: 'Cảnh báo theo vị trí',
              icon: Iconsax.location,
            ),
            const SizedBox(height: 12),
            Obx(() => _SettingsTile(
                  title: 'Bật cảnh báo theo vị trí',
                  subtitle:
                      'Nhận thông báo khi bạn đi vào vùng nguy hiểm',
                  icon: Iconsax.gps,
                  value: controller.settings.value.enableGeofencing,
                  onChanged: (value) => controller.updateSetting(
                    enableGeofencing: value,
                  ),
                )),
            Obx(() {
              if (!controller.settings.value.enableGeofencing) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  _RadiusSlider(
                    value: controller.settings.value.geofenceRadius,
                    onChanged: (value) => controller.updateSetting(
                      geofenceRadius: value,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Alert types section
            _SectionHeader(
              title: 'Loại cảnh báo',
              icon: Iconsax.warning_2,
            ),
            const SizedBox(height: 12),
            Obx(() => _SettingsTile(
                  title: 'Cảnh báo thời tiết',
                  subtitle: 'Bão, lũ lụt, mưa lớn...',
                  icon: Iconsax.cloud_lightning,
                  value: controller.settings.value.enableWeatherAlerts,
                  onChanged: (value) => controller.updateSetting(
                    enableWeatherAlerts: value,
                  ),
                )),
            Obx(() => _SettingsTile(
                  title: 'Cảnh báo sơ tán',
                  subtitle: 'Thông báo về kế hoạch sơ tán, di dời',
                  icon: Iconsax.routing,
                  value: controller.settings.value.enableEvacuationAlerts,
                  onChanged: (value) => controller.updateSetting(
                    enableEvacuationAlerts: value,
                  ),
                )),
            Obx(() => _SettingsTile(
                  title: 'Thông báo cứu trợ',
                  subtitle: 'Điểm phát hàng cứu trợ, nhu yếu phẩm',
                  icon: Iconsax.box,
                  value: controller.settings.value.enableResourceAlerts,
                  onChanged: (value) => controller.updateSetting(
                    enableResourceAlerts: value,
                  ),
                )),
            const SizedBox(height: 24),

            // For volunteers only
            if (controller.isVolunteer.value) ...[
              _SectionHeader(
                title: 'Dành cho tình nguyện viên',
                icon: Iconsax.people,
              ),
              const SizedBox(height: 12),
              Obx(() => _SettingsTile(
                    title: 'Yêu cầu SOS',
                    subtitle: 'Nhận thông báo khi có yêu cầu SOS mới gần bạn',
                    icon: Icons.sos,
                    value: controller.settings.value.enableSosAlerts,
                    onChanged: (value) => controller.updateSetting(
                      enableSosAlerts: value,
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Status section
            _SectionHeader(
              title: 'Trạng thái',
              icon: Iconsax.info_circle,
            ),
            const SizedBox(height: 12),
            _StatusCard(controller: controller),
            const SizedBox(height: 24),

            // Reset button
            Center(
              child: TextButton.icon(
                onPressed: () => _showResetConfirmation(context, controller),
                icon: const Icon(Iconsax.refresh, color: Colors.red),
                label: const Text(
                  'Đặt lại về mặc định',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(
      BuildContext context, NotificationSettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại cài đặt?'),
        content: const Text(
          'Tất cả cài đặt thông báo sẽ được đặt về giá trị mặc định.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              controller.resetToDefaults();
              Navigator.pop(context);
            },
            child: const Text('Đặt lại', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MinhColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Settings tile widget with switch
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MinhColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: MinhColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: MinhColors.primary,
        ),
      ),
    );
  }
}

/// Radius slider widget
class _RadiusSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _RadiusSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bán kính cảnh báo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${value.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MinhColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: 1,
              max: 50,
              divisions: 49,
              activeColor: MinhColors.primary,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 km', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('50 km', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status card widget
class _StatusCard extends StatelessWidget {
  final NotificationSettingsController controller;

  const _StatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusRow(
              label: 'FCM Token',
              value: controller.fcmToken.value != null
                  ? '${controller.fcmToken.value!.substring(0, 20)}...'
                  : 'Chưa có',
              isSuccess: controller.fcmToken.value != null,
            ),
            const SizedBox(height: 8),
            Obx(() => _StatusRow(
                  label: 'Theo dõi vị trí',
                  value: controller.isGeofencingActive.value
                      ? 'Đang hoạt động'
                      : 'Tắt',
                  isSuccess: controller.isGeofencingActive.value,
                )),
            const SizedBox(height: 8),
            Obx(() => _StatusRow(
                  label: 'Topics đăng ký',
                  value: '${controller.subscribedTopics.length} topics',
                  isSuccess: controller.subscribedTopics.isNotEmpty,
                )),
          ],
        ),
      ),
    );
  }
}

/// Status row widget
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSuccess;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSuccess ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Controller for notification settings
class NotificationSettingsController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _settingsKey = 'notification_settings';

  // Observable state
  final settings = NotificationSettingsEntity.defaults().obs;
  final isVolunteer = false.obs;
  final fcmToken = Rxn<String>();
  final isGeofencingActive = false.obs;
  final subscribedTopics = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadStatus();
  }

  void _loadSettings() {
    final savedSettings = _storage.read<Map<String, dynamic>>(_settingsKey);
    if (savedSettings != null) {
      settings.value = NotificationSettingsEntity.fromJson(savedSettings);
    }

    // Check user role
    // TODO: Get actual user role from auth service
    isVolunteer.value = false;
  }

  void _loadStatus() {
    try {
      final notificationService = Get.find<NotificationService>();
      fcmToken.value = notificationService.fcmToken.value;
      subscribedTopics.value = notificationService.subscribedTopics.toList();
    } catch (e) {
      debugPrint('NotificationService not available: $e');
    }

    try {
      final geofencingService = Get.find<GeofencingService>();
      isGeofencingActive.value = geofencingService.isMonitoring.value;
    } catch (e) {
      debugPrint('GeofencingService not available: $e');
    }
  }

  void updateSetting({
    bool? enableCriticalSound,
    bool? enableVibration,
    bool? enableGeofencing,
    double? geofenceRadius,
    bool? enableSosAlerts,
    bool? enableWeatherAlerts,
    bool? enableEvacuationAlerts,
    bool? enableResourceAlerts,
  }) {
    settings.value = settings.value.copyWith(
      enableCriticalSound: enableCriticalSound,
      enableVibration: enableVibration,
      enableGeofencing: enableGeofencing,
      geofenceRadius: geofenceRadius,
      enableSosAlerts: enableSosAlerts,
      enableWeatherAlerts: enableWeatherAlerts,
      enableEvacuationAlerts: enableEvacuationAlerts,
      enableResourceAlerts: enableResourceAlerts,
    );

    _saveSettings();
    _applySettings();
  }

  void _saveSettings() {
    _storage.write(_settingsKey, settings.value.toJson());
  }

  void _applySettings() {
    // Apply geofencing setting
    try {
      final geofencingService = Get.find<GeofencingService>();
      geofencingService.setEnabled(settings.value.enableGeofencing);
      geofencingService.setCheckRadius(settings.value.geofenceRadius);
      isGeofencingActive.value = geofencingService.isMonitoring.value;
    } catch (e) {
      debugPrint('GeofencingService not available: $e');
    }
  }

  void resetToDefaults() {
    settings.value = NotificationSettingsEntity.defaults();
    _saveSettings();
    _applySettings();
  }
}


























