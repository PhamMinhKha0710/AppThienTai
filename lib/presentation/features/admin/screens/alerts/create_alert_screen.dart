import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/presentation/features/admin/controllers/admin_alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CreateAlertScreen extends StatelessWidget {
  final bool isEditing;

  const CreateAlertScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminAlertsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa cảnh báo' : 'Tạo cảnh báo mới'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildSectionTitle('Thông tin cơ bản'),
            const SizedBox(height: 12),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                hintText: 'VD: Cảnh báo bão cấp 10',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.edit),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Content
            TextField(
              controller: controller.contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung *',
                hintText: 'Mô tả chi tiết về cảnh báo...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            // Alert Type
            _buildSectionTitle('Phân loại'),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<AlertType>(
              value: controller.selectedFormType.value,
              decoration: const InputDecoration(
                labelText: 'Loại cảnh báo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.category),
              ),
              items: AlertType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getAlertTypeIcon(type), size: 20),
                      const SizedBox(width: 12),
                      Text(type.viName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedFormType.value = value;
                }
              },
            )),
            const SizedBox(height: 16),

            // Severity
            Obx(() => DropdownButtonFormField<AlertSeverity>(
              value: controller.selectedFormSeverity.value,
              decoration: const InputDecoration(
                labelText: 'Mức độ nghiêm trọng *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.warning_2),
              ),
              items: AlertSeverity.values.map((severity) {
                return DropdownMenuItem(
                  value: severity,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: _getSeverityColor(severity),
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Text(severity.viName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedFormSeverity.value = value;
                }
              },
            )),
            const SizedBox(height: 16),

            // Target Audience
            Obx(() => DropdownButtonFormField<TargetAudience>(
              value: controller.selectedFormAudience.value,
              decoration: const InputDecoration(
                labelText: 'Đối tượng nhận *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.people),
              ),
              items: TargetAudience.values.map((audience) {
                return DropdownMenuItem(
                  value: audience,
                  child: Text(audience.viName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedFormAudience.value = value;
                }
              },
            )),
            const SizedBox(height: 24),

            // Location section
            Obx(() {
              if (controller.selectedFormAudience.value == TargetAudience.locationBased) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Vị trí và bán kính'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.locationController,
                      decoration: const InputDecoration(
                        labelText: 'Tên vị trí',
                        hintText: 'VD: Thành phố Nha Trang',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.location),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.radiusController,
                            decoration: const InputDecoration(
                              labelText: 'Bán kính (km) *',
                              hintText: '10',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Show map picker
                            Get.snackbar(
                              'Thông báo',
                              'Chức năng chọn vị trí trên bản đồ sẽ được cập nhật sau',
                            );
                          },
                          icon: const Icon(Iconsax.map),
                          label: const Text('Chọn trên bản đồ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Province and District
            _buildSectionTitle('Khu vực'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.provinceController,
                    decoration: const InputDecoration(
                      labelText: 'Tỉnh/Thành phố',
                      hintText: 'Khánh Hòa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller.districtController,
                    decoration: const InputDecoration(
                      labelText: 'Quận/Huyện',
                      hintText: 'TP Nha Trang',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Expiry date
            _buildSectionTitle('Thời hạn'),
            const SizedBox(height: 12),
            Obx(() => InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: controller.expiresAt.value ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    controller.expiresAt.value = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.clock),
                    const SizedBox(width: 12),
                    Text(
                      controller.expiresAt.value != null
                          ? 'Hết hạn: ${_formatDateTime(controller.expiresAt.value!)}'
                          : 'Chọn thời gian hết hạn (tùy chọn)',
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),

            // Safety Guide
            _buildSectionTitle('Hướng dẫn an toàn'),
            const SizedBox(height: 12),
            TextField(
              controller: controller.safetyGuideController,
              decoration: const InputDecoration(
                labelText: 'Hướng dẫn xử lý',
                hintText: 'Các bước cần làm để đảm bảo an toàn...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // Images
            _buildSectionTitle('Ảnh minh họa'),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.selectedImages.isEmpty) {
                return OutlinedButton.icon(
                  onPressed: controller.pickImages,
                  icon: const Icon(Iconsax.gallery_add),
                  label: const Text('Thêm ảnh'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...List.generate(
                        controller.selectedImages.length,
                        (index) => Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(controller.selectedImages[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                onPressed: () => controller.removeImage(index),
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  minimumSize: const Size(30, 30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add more button
                      InkWell(
                        onTap: controller.pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Iconsax.add, size: 32),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 32),

            // Submit button
            Obx(() => ElevatedButton(
              onPressed: controller.isUploading.value
                  ? null
                  : () {
                      if (isEditing) {
                        controller.updateAlert();
                      } else {
                        controller.createAlert();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: MinhColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: controller.isUploading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Cập nhật cảnh báo' : 'Tạo cảnh báo'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}







