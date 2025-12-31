import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/data/services/alert_seed_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/admin/controllers/admin_alerts_controller.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/alerts/create_alert_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AdminAlertsScreen extends StatelessWidget {
  const AdminAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAlertsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý cảnh báo'),
        actions: [
          // Seed data button (only in debug mode)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Iconsax.document_download),
              onPressed: () => _showSeedDataDialog(context, controller),
              tooltip: 'Seed dữ liệu mẫu',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAlerts(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  'Đang hoạt động',
                  controller.selectedTab.value == 0,
                  () => controller.selectedTab.value = 0,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  'Tất cả',
                  controller.selectedTab.value == 1,
                  () => controller.selectedTab.value = 1,
                ),
              ),
            ],
          )),

          // Search and filters
          Padding(
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm cảnh báo...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                    ),
                  ),
                  onChanged: controller.search,
                ),
                const SizedBox(height: 12),

                // Filters row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Type filter
                      Obx(() => _buildFilterChip(
                        'Loại',
                        controller.selectedType.value?.viName,
                        () => _showTypeFilter(context, controller),
                      )),
                      const SizedBox(width: 8),

                      // Severity filter
                      Obx(() => _buildFilterChip(
                        'Mức độ',
                        controller.selectedSeverity.value?.viName,
                        () => _showSeverityFilter(context, controller),
                      )),
                      const SizedBox(width: 8),

                      // Audience filter
                      Obx(() => _buildFilterChip(
                        'Đối tượng',
                        controller.selectedAudience.value?.viName,
                        () => _showAudienceFilter(context, controller),
                      )),
                      const SizedBox(width: 8),

                      // Clear filters
                      TextButton.icon(
                        onPressed: controller.clearFilters,
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Xóa bộ lọc'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alerts list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final alerts = controller.currentList;

              if (alerts.isEmpty) {
                return const Center(
                  child: Text('Không có cảnh báo nào'),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertCard(context, alert, controller);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const CreateAlertScreen());
        },
        backgroundColor: MinhColors.primary,
        icon: const Icon(Iconsax.add),
        label: const Text('Tạo cảnh báo'),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? MinhColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? MinhColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selectedValue, VoidCallback onTap) {
    return FilterChip(
      label: Text(selectedValue ?? label),
      selected: selectedValue != null,
      onSelected: (_) => onTap(),
      selectedColor: MinhColors.primary.withOpacity(0.2),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    AlertEntity alert,
    AdminAlertsController controller,
  ) {
    final severityColor = _getSeverityColor(alert.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to detail screen
          // TODO: Navigate to detail
        },
        child: Padding(
          padding: EdgeInsets.all(MinhSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAlertTypeIcon(alert.alertType),
                      color: severityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildBadge(
                              alert.severity.viName,
                              severityColor,
                            ),
                            _buildBadge(
                              alert.alertType.viName,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          controller.startEdit(alert);
                          Get.to(() => CreateAlertScreen(isEditing: true));
                          break;
                        case 'deactivate':
                          controller.deactivateAlert(alert.id);
                          break;
                        case 'delete':
                          controller.deleteAlert(alert.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      if (alert.isActive)
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_off, size: 18),
                              SizedBox(width: 8),
                              Text('Vô hiệu hóa'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                alert.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),

              // Meta info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildMetaInfo(
                    Iconsax.user,
                    alert.targetAudience.viName,
                  ),
                  if (alert.location != null)
                    _buildMetaInfo(
                      Iconsax.location,
                      alert.location!,
                    ),
                  _buildMetaInfo(
                    Iconsax.clock,
                    _formatDateTime(alert.createdAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showTypeFilter(BuildContext context, AdminAlertsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn loại cảnh báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tất cả'),
              onTap: () {
                controller.filterByType(null);
                Get.back();
              },
            ),
            ...AlertType.values.map((type) => ListTile(
              leading: Icon(_getAlertTypeIcon(type)),
              title: Text(type.viName),
              onTap: () {
                controller.filterByType(type);
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSeverityFilter(BuildContext context, AdminAlertsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn mức độ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tất cả'),
              onTap: () {
                controller.filterBySeverity(null);
                Get.back();
              },
            ),
            ...AlertSeverity.values.map((severity) => ListTile(
              leading: Icon(
                Icons.circle,
                color: _getSeverityColor(severity),
              ),
              title: Text(severity.viName),
              onTap: () {
                controller.filterBySeverity(severity);
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAudienceFilter(BuildContext context, AdminAlertsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn đối tượng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tất cả'),
              onTap: () {
                controller.filterByAudience(null);
                Get.back();
              },
            ),
            ...TargetAudience.values.map((audience) => ListTile(
              title: Text(audience.viName),
              onTap: () {
                controller.filterByAudience(audience);
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSeedDataDialog(
    BuildContext context,
    AdminAlertsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Seed Dữ Liệu Mẫu'),
        content: const Text(
          'Bạn có muốn tạo dữ liệu mẫu cảnh báo vào Firestore? '
          'Hành động này sẽ tạo khoảng 17 cảnh báo mẫu cho cả nạn nhân và tình nguyện viên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _seedAlertsData(controller);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedAlertsData(AdminAlertsController controller) async {
    try {
      final seedService = getIt<AlertSeedService>();
      
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await seedService.seedAlerts();

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Thành công',
        'Đã tạo dữ liệu mẫu cảnh báo thành công!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Refresh alerts list
      await controller.loadAlerts();
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Lỗi',
        'Không thể tạo dữ liệu mẫu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}








