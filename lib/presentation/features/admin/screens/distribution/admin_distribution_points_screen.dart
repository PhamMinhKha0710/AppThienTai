import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AdminDistributionPointsScreen extends StatelessWidget {
  const AdminDistributionPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_AdminDistributionController());

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text("Quản lý điểm phân phối"),
        showBackArrow: true,
        action: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: () => _showAddEditDialog(context, controller),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shelters')
            .orderBy('CreatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.home_2, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có điểm phân phối nào',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(context, controller),
                    icon: const Icon(Iconsax.add),
                    label: const Text('Thêm điểm phân phối'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => controller.seedSampleData(),
                    icon: const Icon(Iconsax.archive_add),
                    label: const Text('Tạo dữ liệu mẫu'),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(MinhSizes.md),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _DistributionPointCard(
                id: doc.id,
                data: data,
                controller: controller,
                onEdit: () => _showAddEditDialog(context, controller, doc.id, data),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, controller),
        icon: const Icon(Iconsax.add),
        label: const Text('Thêm mới'),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    _AdminDistributionController controller, [
    String? docId,
    Map<String, dynamic>? existingData,
  ]) {
    final isEditing = docId != null;
    
    controller.nameController.text = existingData?['Name'] ?? '';
    controller.addressController.text = existingData?['Address'] ?? '';
    controller.latController.text = (existingData?['Lat'] ?? '').toString();
    controller.lngController.text = (existingData?['Lng'] ?? '').toString();
    controller.capacityController.text = (existingData?['Capacity'] ?? 100).toString();
    controller.phoneController.text = existingData?['ContactPhone'] ?? '';
    controller.distributionTimeController.text = existingData?['DistributionTime'] ?? '08:00 - 17:00';
    controller.descriptionController.text = existingData?['Description'] ?? '';
    controller.amenitiesController.text = (existingData?['Amenities'] as List<dynamic>?)?.join(', ') ?? '';

    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Sửa điểm phân phối' : 'Thêm điểm phân phối'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên điểm *',
                  prefixIcon: Icon(Iconsax.home_2),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ *',
                  prefixIcon: Icon(Iconsax.location),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Latitude *',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Longitude *',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sức chứa',
                        prefixIcon: Icon(Iconsax.people),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Điện thoại',
                        prefixIcon: Icon(Iconsax.call),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.distributionTimeController,
                decoration: const InputDecoration(
                  labelText: 'Giờ phát hàng',
                  prefixIcon: Icon(Iconsax.clock),
                  hintText: '08:00 - 17:00',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.amenitiesController,
                decoration: const InputDecoration(
                  labelText: 'Vật phẩm (cách nhau bởi dấu phẩy)',
                  prefixIcon: Icon(Iconsax.box),
                  hintText: 'Gạo, Mì gói, Nước uống',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Iconsax.document_text),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isEditing) {
                await controller.updateDistributionPoint(docId);
              } else {
                await controller.addDistributionPoint();
              }
              Get.back();
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }
}

class _DistributionPointCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final _AdminDistributionController controller;
  final VoidCallback onEdit;

  const _DistributionPointCard({
    required this.id,
    required this.data,
    required this.controller,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = data['IsActive'] ?? true;
    final capacity = data['Capacity'] ?? 0;
    final occupancy = data['CurrentOccupancy'] ?? 0;
    final available = capacity - occupancy;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(MinhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Iconsax.home_2,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['Name'] ?? 'Không tên',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['Address'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade50 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Hoạt động' : 'Tạm dừng',
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Iconsax.people,
                  label: 'Sức chứa: $capacity',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Iconsax.tick_circle,
                  label: 'Còn trống: $available',
                  color: available > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Iconsax.edit, size: 18),
                  label: const Text('Sửa'),
                ),
                TextButton.icon(
                  onPressed: () => controller.toggleActive(id, isActive),
                  icon: Icon(
                    isActive ? Iconsax.pause : Iconsax.play,
                    size: 18,
                  ),
                  label: Text(isActive ? 'Tạm dừng' : 'Kích hoạt'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, id),
                  icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa điểm phân phối này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteDistributionPoint(docId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDistributionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final capacityController = TextEditingController();
  final phoneController = TextEditingController();
  final distributionTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final amenitiesController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    latController.dispose();
    lngController.dispose();
    capacityController.dispose();
    phoneController.dispose();
    distributionTimeController.dispose();
    descriptionController.dispose();
    amenitiesController.dispose();
    super.onClose();
  }

  Future<void> addDistributionPoint() async {
    try {
      if (nameController.text.isEmpty || addressController.text.isEmpty) {
        MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng nhập tên và địa chỉ');
        return;
      }

      final lat = double.tryParse(latController.text) ?? 0.0;
      final lng = double.tryParse(lngController.text) ?? 0.0;
      
      if (lat == 0.0 || lng == 0.0) {
        MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng nhập tọa độ hợp lệ');
        return;
      }

      final amenities = amenitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _firestore.collection('shelters').add({
        'Name': nameController.text,
        'Address': addressController.text,
        'Lat': lat,
        'Lng': lng,
        'Capacity': int.tryParse(capacityController.text) ?? 100,
        'CurrentOccupancy': 0,
        'ContactPhone': phoneController.text,
        'DistributionTime': distributionTimeController.text.isEmpty 
            ? '08:00 - 17:00' 
            : distributionTimeController.text,
        'Description': descriptionController.text,
        'Amenities': amenities,
        'IsActive': true,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });

      MinhLoaders.successSnackBar(title: 'Thành công', message: 'Đã thêm điểm phân phối');
      _clearForm();
    } catch (e) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Không thể thêm: $e');
    }
  }

  Future<void> updateDistributionPoint(String docId) async {
    try {
      final lat = double.tryParse(latController.text) ?? 0.0;
      final lng = double.tryParse(lngController.text) ?? 0.0;

      final amenities = amenitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _firestore.collection('shelters').doc(docId).update({
        'Name': nameController.text,
        'Address': addressController.text,
        'Lat': lat,
        'Lng': lng,
        'Capacity': int.tryParse(capacityController.text) ?? 100,
        'ContactPhone': phoneController.text,
        'DistributionTime': distributionTimeController.text,
        'Description': descriptionController.text,
        'Amenities': amenities,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });

      MinhLoaders.successSnackBar(title: 'Thành công', message: 'Đã cập nhật');
      _clearForm();
    } catch (e) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Không thể cập nhật: $e');
    }
  }

  Future<void> deleteDistributionPoint(String docId) async {
    try {
      await _firestore.collection('shelters').doc(docId).delete();
      MinhLoaders.successSnackBar(title: 'Thành công', message: 'Đã xóa điểm phân phối');
    } catch (e) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Không thể xóa: $e');
    }
  }

  Future<void> toggleActive(String docId, bool currentStatus) async {
    try {
      await _firestore.collection('shelters').doc(docId).update({
        'IsActive': !currentStatus,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: currentStatus ? 'Đã tạm dừng' : 'Đã kích hoạt',
      );
    } catch (e) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Không thể cập nhật: $e');
    }
  }

  Future<void> seedSampleData() async {
    try {
      final samplePoints = [
        {
          'Name': 'Điểm cứu trợ UBND Phường 1',
          'Address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
          'Lat': 10.7769,
          'Lng': 106.7009,
          'Description': 'Điểm phát lương thực, nước uống và nhu yếu phẩm',
          'Capacity': 200,
          'CurrentOccupancy': 45,
          'IsActive': true,
          'ContactPhone': '028-1234-5678',
          'Amenities': ['Gạo', 'Mì gói', 'Nước uống', 'Quần áo', 'Chăn màn'],
          'DistributionTime': '08:00 - 17:00',
        },
        {
          'Name': 'Trạm cứu trợ Hội Chữ Thập Đỏ',
          'Address': '456 Lê Lợi, Quận 3, TP.HCM',
          'Lat': 10.7756,
          'Lng': 106.6878,
          'Description': 'Hỗ trợ y tế và nhu yếu phẩm',
          'Capacity': 150,
          'CurrentOccupancy': 30,
          'IsActive': true,
          'ContactPhone': '028-8765-4321',
          'Amenities': ['Thuốc men', 'Băng gạc', 'Nước uống', 'Thực phẩm'],
          'DistributionTime': '07:00 - 19:00',
        },
        {
          'Name': 'Điểm phân phối Trường THPT Lê Quý Đôn',
          'Address': '789 Trần Hưng Đạo, Quận 5, TP.HCM',
          'Lat': 10.7550,
          'Lng': 106.6700,
          'Description': 'Điểm tạm trú và phát lương thực',
          'Capacity': 300,
          'CurrentOccupancy': 120,
          'IsActive': true,
          'ContactPhone': '028-9999-8888',
          'Amenities': ['Gạo', 'Thực phẩm khô', 'Nước uống', 'Quần áo', 'Đồ dùng cá nhân'],
          'DistributionTime': '06:00 - 20:00',
        },
        {
          'Name': 'Trạm cứu trợ MTTQ Quận 7',
          'Address': '321 Nguyễn Thị Thập, Quận 7, TP.HCM',
          'Lat': 10.7380,
          'Lng': 106.7220,
          'Description': 'Điểm tiếp nhận và phân phối hàng cứu trợ',
          'Capacity': 250,
          'CurrentOccupancy': 80,
          'IsActive': true,
          'ContactPhone': '028-7777-6666',
          'Amenities': ['Gạo', 'Mì gói', 'Dầu ăn', 'Nước mắm', 'Quần áo'],
          'DistributionTime': '08:00 - 18:00',
        },
        {
          'Name': 'Điểm hỗ trợ Nhà Văn hóa Thanh Niên',
          'Address': '4 Phạm Ngọc Thạch, Quận 1, TP.HCM',
          'Lat': 10.7820,
          'Lng': 106.6970,
          'Description': 'Hỗ trợ thực phẩm và đồ dùng sinh hoạt',
          'Capacity': 180,
          'CurrentOccupancy': 55,
          'IsActive': true,
          'ContactPhone': '028-3823-4567',
          'Amenities': ['Thực phẩm', 'Nước uống', 'Sữa', 'Bánh kẹo', 'Đồ chơi trẻ em'],
          'DistributionTime': '09:00 - 17:00',
        },
      ];

      for (final point in samplePoints) {
        await _firestore.collection('shelters').add({
          ...point,
          'CreatedAt': FieldValue.serverTimestamp(),
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã tạo ${samplePoints.length} điểm phân phối mẫu',
      );
    } catch (e) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Không thể tạo dữ liệu mẫu: $e');
    }
  }

  void _clearForm() {
    nameController.clear();
    addressController.clear();
    latController.clear();
    lngController.clear();
    capacityController.clear();
    phoneController.clear();
    distributionTimeController.clear();
    descriptionController.clear();
    amenitiesController.clear();
  }
}
