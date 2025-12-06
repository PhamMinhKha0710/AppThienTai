import 'package:cuutrobaolu/presentation/features/shop/controllers/create_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';

class CreateRequestScreen extends StatelessWidget {
  CreateRequestScreen({super.key});

  final controller = Get.put(CreateRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MinhAppbar(
        title: Text("Cứu Trợ Hỗ Trợ"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Section - Manual Selection
              _buildManualAddressSection(),
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: controller.titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề *',
                  hintText: 'Ví dụ: Cần hỗ trợ thực phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 100,
                validator: controller.validateTitle,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết *',
                  hintText: 'Mô tả tình huống và nhu cầu của bạn...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
                validator: controller.validateDescription,
              ),
              const SizedBox(height: 16),

              // Request Type Selection
              _buildRequestTypeSection(),
              const SizedBox(height: 16),

              // Severity Selection
              _buildSeveritySection(),
              const SizedBox(height: 16),

              // Contact Field
              TextFormField(
                controller: controller.contactController,
                decoration: const InputDecoration(
                  labelText: 'Thông tin liên hệ *',
                  hintText: 'Số điện thoại hoặc thông tin liên lạc khác',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: controller.validateContact,
              ),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.createHelpRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'GỬI YÊU CẦU TRỢ GIÚP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualAddressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Địa chỉ yêu cầu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Hiển thị địa chỉ hiện tại nếu có
                      Obx(() {
                        final address = controller.currentAddress;
                        if (address != null && address.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      // Hiển thị lỗi nếu có
                      Obx(() {
                        final error = controller.locationError;
                        if (error != null && error.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              error,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                Obx(() => controller.isLocationLoading
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: controller.getCurrentLocation,
                  tooltip: 'Lấy vị trí hiện tại',
                )),
              ],
            ),
            const SizedBox(height: 12),

            // Province Selector
            Obx(() => _buildAddressDropdown(
              title: 'Tỉnh/Thành phố *',
              hintText: 'Chọn tỉnh/thành phố',
              value: controller.selectedProvince.value?.name,
              items: controller.filteredProvinces.map((p) => p.name).toList(),
              onSearchChanged: (query) => controller.filterProvinces(query).catchError((e) => print('Error: $e')),
              onChanged: (value) => controller.selectProvince(value).catchError((e) => print('Error: $e')),
            )),

            const SizedBox(height: 12),

            // District Selector (only for v1)
            // Thay thế phần District Selector trong _buildManualAddressSection()
            Obx(() {
              final shouldShowDistrict =
                  controller.selectedProvince.value != null &&
                      controller.currentVersion.value == AdministrativeDivisionVersion.v1;

              if (shouldShowDistrict) {
                print('Should show district selector');
                print('Filtered districts count: ${controller.filteredDistricts.length}');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Quận/Huyện *',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Hiển thị số lượng quận/huyện để debug
                    if (controller.filteredDistricts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.yellow[100],
                        child: const Text(
                          'Đang tải quận/huyện...',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButton<String>(
                        value: controller.selectedDistrict.value?.name,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: controller.filteredDistricts.isEmpty
                            ? const Text('Đang tải...')
                            : const Text('Chọn quận/huyện'),
                        items: controller.filteredDistricts
                            .map(
                              (d) => DropdownMenuItem<String>(
                            value: d.name,
                            child: Text('${d.name} (${d.code})', overflow: TextOverflow.ellipsis),
                          ),
                        )
                            .toList(),
                        onChanged: controller.filteredDistricts.isEmpty
                            ? null
                            : (value) => controller.selectDistrict(value).catchError((e) => print('Error: $e')),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Ward Selector
            Obx(() {
              final shouldShowWard =
                  (controller.currentVersion.value == AdministrativeDivisionVersion.v2 &&
                      controller.selectedProvince.value != null) ||
                      (controller.currentVersion.value == AdministrativeDivisionVersion.v1 &&
                          controller.selectedDistrict.value != null);

              if (shouldShowWard) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Phường/Xã *',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButton<String>(
                        value: controller.selectedWard.value?.name,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Chọn phường/xã'),
                        items: controller.filteredWards
                            .map(
                              (w) => DropdownMenuItem<String>(
                            value: w.name,
                            child: Text(w.name, overflow: TextOverflow.ellipsis),
                          ),
                        )
                            .toList(),
                        onChanged: (value) => controller.selectWard(value),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 12),

            // Detailed Address
            TextFormField(
              controller: controller.detailedAddressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ chi tiết *',
                hintText: 'Số nhà, tên đường, tòa nhà...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: controller.validateAddress,
            ),

            // Version Toggle
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phiên bản địa chỉ:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Obx(() => Switch(
                  value: controller.currentVersion.value == AdministrativeDivisionVersion.v2,
                  onChanged: (value) {
                    controller.switchVersion(value
                        ? AdministrativeDivisionVersion.v2
                        : AdministrativeDivisionVersion.v1);
                  },
                )),
              ],
            ),
            Obx(() => Text(
              controller.currentVersion.value == AdministrativeDivisionVersion.v1
                  ? 'Phiên bản 3 cấp: Tỉnh → Huyện → Xã'
                  : 'Phiên bản 2 cấp: Tỉnh → Xã',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDropdown({
    required String title,
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String) onSearchChanged,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(hintText),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại yêu cầu *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildRequestTypeOption('food', 'Thực phẩm', Icons.restaurant),
            _buildRequestTypeOption('water', 'Nước uống', Icons.water_drop),
            _buildRequestTypeOption('medicine', 'Thuốc men', Icons.medical_services),
            _buildRequestTypeOption('clothes', 'Quần áo', Icons.checkroom),
            _buildRequestTypeOption('shelter', 'Nơi ở', Icons.home),
            _buildRequestTypeOption('other', 'Khác', Icons.more_horiz),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestTypeOption(String type, String label, IconData icon) {
    return Obx(() => ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: controller.selectedType.value == type,
      onSelected: (selected) => controller.updateType(type),
      selectedColor: Colors.blue.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: controller.selectedType.value == type ? Colors.blue : Colors.black,
        fontWeight: controller.selectedType.value == type ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: controller.selectedType.value == type ? Colors.blue : Colors.grey[300]!,
          width: controller.selectedType.value == type ? 2 : 1,
        ),
      ),
    ));
  }

  Widget _buildSeveritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mức độ khẩn cấp *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSeverityOption('low', 'Thấp'),
            const SizedBox(width: 12),
            _buildSeverityOption('medium', 'Trung bình'),
            const SizedBox(width: 12),
            _buildSeverityOption('high', 'Cao'),
          ],
        ),
      ],
    );
  }

  Widget _buildSeverityOption(String severity, String label) {
    return Expanded(
      child: Obx(() => GestureDetector(
        onTap: () => controller.updateSeverity(severity),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: controller.selectedSeverity.value == severity
                ? controller.getSeverityColor(severity).withOpacity(0.2)
                : Colors.grey[100],
            border: Border.all(
              color: controller.selectedSeverity.value == severity
                  ? controller.getSeverityColor(severity)
                  : Colors.grey[300]!,
              width: controller.selectedSeverity.value == severity ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                severity == 'low'
                    ? Icons.info_outline
                    : severity == 'medium'
                    ? Icons.warning_outlined
                    : Icons.error_outline,
                color: controller.getSeverityColor(severity),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: controller.getSeverityColor(severity),
                  fontWeight: controller.selectedSeverity.value == severity
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
