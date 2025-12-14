import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/presentation/features/admin/controllers/admin_sos_controller.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminSOSScreen extends StatelessWidget {
  const AdminSOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSOSController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý SOS'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export_1),
            onPressed: () => controller.exportToExcel(),
            tooltip: 'Export Excel',
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.resetFilters(),
            tooltip: 'Reset filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(MinhSizes.md),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm theo tiêu đề, mô tả, địa chỉ...',
                    prefixIcon: Icon(Iconsax.search_normal),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    controller.searchQuery.value = value;
                    controller.applyFilters();
                  },
                ),
                const SizedBox(height: MinhSizes.spaceBtwItems),
                
                // Filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Status filter
                    Obx(() => DropdownButton<String>(
                      value: controller.selectedStatus.value,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                        DropdownMenuItem(value: 'pending', child: Text('Chờ xử lý')),
                        DropdownMenuItem(value: 'inProgress', child: Text('Đang xử lý')),
                        DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedStatus.value = value;
                          controller.applyFilters();
                        }
                      },
                    )),
                    
                    // Severity filter
                    Obx(() => DropdownButton<String>(
                      value: controller.selectedSeverity.value,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả mức độ')),
                        DropdownMenuItem(value: 'urgent', child: Text('Khẩn cấp')),
                        DropdownMenuItem(value: 'high', child: Text('Cao')),
                        DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                        DropdownMenuItem(value: 'low', child: Text('Thấp')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedSeverity.value = value;
                          controller.applyFilters();
                        }
                      },
                    )),
                    
                    // Type filter
                    Obx(() => DropdownButton<String>(
                      value: controller.selectedType.value,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả loại')),
                        DropdownMenuItem(value: 'food', child: Text('Thực phẩm')),
                        DropdownMenuItem(value: 'water', child: Text('Nước')),
                        DropdownMenuItem(value: 'medicine', child: Text('Thuốc')),
                        DropdownMenuItem(value: 'shelter', child: Text('Trú ẩn')),
                        DropdownMenuItem(value: 'rescue', child: Text('Cứu hộ')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedType.value = value;
                          controller.applyFilters();
                        }
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),
          
          // Results count
          Obx(() {
            final total = controller.allRequests.length;
            final filtered = controller.filteredRequests.length;
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MinhSizes.md,
                vertical: 8,
              ),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hiển thị $filtered / $total yêu cầu',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (filtered != total)
                    TextButton(
                      onPressed: () => controller.resetFilters(),
                      child: const Text('Xóa bộ lọc'),
                    ),
                ],
              ),
            );
          }),
          
          // Requests list
          Expanded(
            child: Obx(() {
              final requests = controller.filteredRequests;
              
              if (requests.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.note, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Không có yêu cầu nào'),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(MinhSizes.md),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _SOSCard(
                    request: request,
                    controller: controller,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SOSCard extends StatelessWidget {
  final HelpRequest request;
  final AdminSOSController controller;

  const _SOSCard({
    required this.request,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Status colors
    Color statusColor = Colors.orange;
    String statusText = 'Chờ xử lý';
    IconData statusIcon = Iconsax.clock;
    
    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Chờ xử lý';
        statusIcon = Iconsax.clock;
        break;
      case RequestStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'Đang xử lý';
        statusIcon = Iconsax.refresh;
        break;
      case RequestStatus.completed:
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        statusIcon = Iconsax.tick_circle;
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Đã hủy';
        statusIcon = Iconsax.close_circle;
        break;
    }
    
    // Severity colors
    Color severityColor = Colors.orange;
    switch (request.severity) {
      case RequestSeverity.urgent:
        severityColor = Colors.red;
        break;
      case RequestSeverity.high:
        severityColor = Colors.orange;
        break;
      case RequestSeverity.medium:
        severityColor = Colors.yellow.shade700;
        break;
      case RequestSeverity.low:
        severityColor = Colors.green;
        break;
    }
    
    final createdAt = DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor, size: 28),
        title: Row(
          children: [
            Expanded(
              child: Text(
                request.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.severity.viName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              request.address,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Iconsax.calendar, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  createdAt,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(MinhSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                const Text(
                  'Mô tả:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(request.description),
                const SizedBox(height: 12),
                
                // Contact
                Row(
                  children: [
                    const Icon(Iconsax.call, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Liên hệ: ${request.contact}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Type
                Row(
                  children: [
                    const Icon(Iconsax.tag, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Loại: ${request.type.viName}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Actions
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (request.status == RequestStatus.pending)
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAssignVolunteerDialog(context, request.id);
                        },
                        icon: const Icon(Iconsax.user, size: 16),
                        label: const Text('Phân công'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (request.status == RequestStatus.inProgress)
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.updateStatus(request.id, RequestStatus.completed);
                        },
                        icon: const Icon(Iconsax.tick_circle, size: 16),
                        label: const Text('Hoàn thành'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showMapDialog(context, request);
                      },
                      icon: const Icon(Iconsax.map, size: 16),
                      label: const Text('Xem bản đồ'),
                    ),
                    if (request.status != RequestStatus.completed)
                      OutlinedButton.icon(
                        onPressed: () {
                          _showCancelDialog(context, request.id);
                        },
                        icon: const Icon(Iconsax.close_circle, size: 16),
                        label: const Text('Hủy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAssignVolunteerDialog(BuildContext context, String requestId) {
    final request = controller.allRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => controller.allRequests.first,
    );
    
    // Use Rx variable for selected volunteer
    final selectedVolunteerId = Rxn<String>();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Phân công tình nguyện viên'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.getAvailableVolunteers(request.lat, request.lng),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text('Không có tình nguyện viên nào'),
                ),
              );
            }
            
            final volunteers = snapshot.data!;
            
            return SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  const Text('Chọn tình nguyện viên:'),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() => ListView.builder(
                      itemCount: volunteers.length,
                      itemBuilder: (context, index) {
                        final volunteer = volunteers[index];
                        final distance = volunteer['distance'] as double?;
                        
                        return RadioListTile<String>(
                          title: Text(volunteer['name'] as String),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (volunteer['email'] != null && (volunteer['email'] as String).isNotEmpty)
                                Text(
                                  volunteer['email'] as String,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              if (distance != null)
                                Text(
                                  'Khoảng cách: ${distance.toStringAsFixed(1)} km',
                                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                                ),
                            ],
                          ),
                          value: volunteer['id'] as String,
                          groupValue: selectedVolunteerId.value,
                          onChanged: (value) {
                            selectedVolunteerId.value = value;
                          },
                        );
                      },
                    )),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          Obx(() => ElevatedButton(
            onPressed: selectedVolunteerId.value == null
                ? null
                : () async {
                    await controller.assignVolunteer(requestId, selectedVolunteerId.value!);
                    Get.back();
                  },
            child: const Text('Phân công'),
          )),
        ],
      ),
    );
  }
  
  void _showMapDialog(BuildContext context, HelpRequest request) {
    Get.dialog(
      Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              AppBar(
                title: const Text('Vị trí cần cứu trợ'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(request.lat, request.lng),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(request.lat, request.lng),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.address,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showCancelDialog(BuildContext context, String requestId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hủy yêu cầu'),
        content: const Text('Bạn có chắc muốn hủy yêu cầu này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              final controller = Get.find<AdminSOSController>();
              controller.updateStatus(requestId, RequestStatus.cancelled);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );
  }
}

