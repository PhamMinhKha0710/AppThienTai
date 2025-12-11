import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_receive_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/map/victim_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VictimReceiveScreen extends StatelessWidget {
  const VictimReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimReceiveController());

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text("Đăng ký nhận hỗ trợ"),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(MinhSizes.md),
            color: Colors.grey.shade100,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm điểm phân phối gần nhất...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                ),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
            ),
          ),

          // Tabs
          Container(
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Điểm phân phối',
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Đăng ký của tôi',
                    isSelected: false,
                    onTap: () {
                      // TODO: Switch to registrations tab
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Access observables directly in Obx to ensure proper tracking
              final allPoints = controller.nearbyDistributionPoints;
              final query = controller.searchQuery.value;
              
              // Filter points directly here
              final points = query.isEmpty
                  ? allPoints
                  : allPoints.where((point) {
                      final name = (point['name'] ?? '').toString().toLowerCase();
                      final address = (point['address'] ?? '').toString().toLowerCase();
                      final queryLower = query.toLowerCase();
                      return name.contains(queryLower) || address.contains(queryLower);
                    }).toList();
              
              if (points.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.location, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy điểm phân phối nào',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => controller.refreshData(),
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('Làm mới'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(MinhSizes.md),
                  itemCount: points.length,
                  itemBuilder: (context, index) {
                    final point = points[index];
                    return _DistributionPointCard(
                      point: point,
                      controller: controller,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _DistributionPointCard extends StatelessWidget {
  final Map<String, dynamic> point;
  final VictimReceiveController controller;

  const _DistributionPointCard({
    required this.point,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final distance = point['distance'] as double? ?? 0.0;
    final available = point['available'] as int? ?? 0;
    final percent = point['percent'] as int? ?? 0;
    final distributionTime = point['distributionTime'] as String? ?? '08:00 - 17:00';

    Color statusColor = Colors.green;
    if (percent >= 90) {
      statusColor = Colors.red;
    } else if (percent >= 70) {
      statusColor = Colors.orange;
    }

    // Check if user already registered - wrap in Obx
    return Obx(() {
      final isRegistered = controller.myRegistrations.any(
        (reg) => reg['PointId'] == point['id'] && reg['Status'] != 'cancelled',
      );

      return Card(
        margin: const EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
        child: InkWell(
          onTap: () {
            // Show details
            _showPointDetails(context, point, isRegistered);
          },
          child: Padding(
            padding: const EdgeInsets.all(MinhSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.home_2, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            point['name'] ?? 'Điểm phân phối',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Iconsax.location, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  point['address'] ?? '',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isRegistered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Đã đăng ký',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Iconsax.routing,
                      label: 'Khoảng cách',
                      value: distance > 0 
                          ? '${distance.toStringAsFixed(1)} km'
                          : 'Gần đây',
                      color: Colors.blue,
                    ),
                    _InfoChip(
                      icon: Iconsax.clock,
                      label: 'Giờ phát',
                      value: distributionTime,
                      color: Colors.orange,
                    ),
                    _InfoChip(
                      icon: Iconsax.people,
                      label: 'Còn trống',
                      value: '$available',
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.to(() => VictimMapScreen());
                        },
                        icon: const Icon(Iconsax.map, size: 16),
                        label: const Text('Xem bản đồ'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isRegistered
                            ? null
                            : () => controller.registerForDistribution(
                                  point['id'] as String,
                                  point,
                                ),
                        icon: Icon(
                          isRegistered ? Iconsax.tick_circle : Iconsax.receive_square,
                          size: 16,
                        ),
                        label: Text(isRegistered ? 'Đã đăng ký' : 'Đăng ký nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered ? Colors.grey : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showPointDetails(BuildContext context, Map<String, dynamic> point, bool isRegistered) {
    final distance = point['distance'] as double? ?? 0.0;
    final available = point['available'] as int? ?? 0;
    final capacity = point['capacity'] as int? ?? 0;
    final distributionTime = point['distributionTime'] as String? ?? '08:00 - 17:00';
    final items = point['items'] as List<dynamic>? ?? <String>[];
    final pointId = point['id'] as String? ?? '';

    Get.bottomSheet(
      Obx(() {
        // Re-check registration status inside Obx
        final currentIsRegistered = controller.myRegistrations.any(
          (reg) => reg['PointId'] == pointId && reg['Status'] != 'cancelled',
        );
        
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Iconsax.home_2, color: Colors.blue, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point['name'] ?? 'Điểm phân phối',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (currentIsRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Đã đăng ký',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Iconsax.location,
              label: 'Địa chỉ',
              value: point['address'] ?? '',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Iconsax.routing,
              label: 'Khoảng cách',
              value: distance > 0 
                  ? '${distance.toStringAsFixed(1)} km'
                  : 'Gần đây',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Iconsax.clock,
              label: 'Giờ phát hàng',
              value: distributionTime,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Iconsax.people,
                    label: 'Sức chứa',
                    value: '$capacity',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Iconsax.tick_circle,
                    label: 'Còn trống',
                    value: '$available',
                    color: available > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Vật phẩm có sẵn:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  return Chip(
                    label: Text(item.toString()),
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.to(() => VictimMapScreen());
                    },
                    icon: const Icon(Iconsax.map),
                    label: const Text('Xem bản đồ'),
                  ),
                ),
                const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: currentIsRegistered
                            ? null
                            : () {
                                Get.back();
                                controller.registerForDistribution(
                                  pointId,
                                  point,
                                );
                              },
                        icon: Icon(
                          currentIsRegistered ? Iconsax.tick_circle : Iconsax.receive_square,
                        ),
                        label: Text(currentIsRegistered ? 'Đã đăng ký' : 'Đăng ký nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentIsRegistered ? Colors.grey : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

