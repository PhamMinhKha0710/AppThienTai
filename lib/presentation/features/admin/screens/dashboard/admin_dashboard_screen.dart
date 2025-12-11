import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Quản Trị'),
        actions: [
          Obx(() {
            final pending = controller.pendingSOS.value;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.notification),
                  onPressed: () {
                    controller.navigateToSOS();
                  },
                ),
                if (pending > 0)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pending > 99 ? '99+' : '$pending',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(MinhSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Banner
                _buildStatsCards(controller),
                const SizedBox(height: MinhSizes.spaceBtwSections),

                // Charts
                _buildCharts(controller),
                
                // Map + Recent SOS (2 columns on tablet, stack on mobile)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Tablet layout
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildMapWidget(controller),
                          ),
                          const SizedBox(width: MinhSizes.spaceBtwItems),
                          Expanded(
                            flex: 1,
                            child: _buildRightColumn(controller),
                          ),
                        ],
                      );
                    } else {
                      // Mobile layout
                      return Column(
                        children: [
                          _buildMapWidget(controller),
                          const SizedBox(height: MinhSizes.spaceBtwSections),
                          _buildRightColumn(controller),
                        ],
                      );
                    }
                  },
                ),
                
                const SizedBox(height: MinhSizes.spaceBtwSections),
                
                // Quick Actions
                _buildQuickActions(controller),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildStatsCards(AdminDashboardController controller) {
    return Obx(() {
      return Wrap(
        spacing: MinhSizes.spaceBtwItems,
        runSpacing: MinhSizes.spaceBtwItems,
        children: [
          _StatCard(
            icon: Iconsax.danger,
            label: 'SOS Chờ xử lý',
            value: '${controller.pendingSOS.value}',
            color: Colors.red,
            onTap: () => controller.navigateToSOS(),
          ),
          _StatCard(
            icon: Iconsax.clock,
            label: 'Đang xử lý',
            value: '${controller.inProgressSOS.value}',
            color: Colors.orange,
            onTap: () => controller.navigateToSOS(),
          ),
          _StatCard(
            icon: Iconsax.tick_circle,
            label: 'Hoàn thành',
            value: '${controller.completedSOS.value}',
            color: Colors.green,
            onTap: () {},
          ),
          _StatCard(
            icon: Iconsax.user,
            label: 'TNV Hoạt động',
            value: '${controller.activeVolunteers.value}',
            color: Colors.blue,
            onTap: () {
              // TODO: Navigate to volunteers
            },
          ),
        ],
      );
    });
  }

  Widget _buildCharts(AdminDashboardController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        
        if (isWide) {
          // Tablet/Desktop: Row layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(MinhSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Phân bổ loại SOS (hôm nay)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: MinhSizes.spaceBtwItems),
                        Obx(() {
                          final data = controller.sosTypeDistribution;
                          if (data.isEmpty) {
                            return const Text('Chưa có dữ liệu');
                          }
                          final total = data.fold<int>(0, (sum, e) => sum + (e['count'] as int));
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: data.map((e) {
                              final count = e['count'] as int;
                              final percent = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
                              return _TypeChip(
                                label: e['type'] as String,
                                count: count,
                                percent: percent,
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: MinhSizes.spaceBtwItems),
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(MinhSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Số ca xử lý 7 ngày qua', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: MinhSizes.spaceBtwItems),
                        SizedBox(
                          height: 160,
                          child: Obx(() {
                            final data = controller.weeklyStats;
                            if (data.isEmpty) return const Text('Chưa có dữ liệu');
                            final max = data.fold<int>(0, (m, e) => (e['count'] as int) > m ? e['count'] as int : m);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: data.map((e) {
                                final count = e['count'] as int;
                                return _WeeklyBar(
                                  label: e['day'] as String,
                                  value: count,
                                  maxValue: max == 0 ? 1 : max,
                                );
                              }).toList(),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile: Column layout
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(MinhSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Phân bổ loại SOS (hôm nay)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: MinhSizes.spaceBtwItems),
                      Obx(() {
                        final data = controller.sosTypeDistribution;
                        if (data.isEmpty) {
                          return const Text('Chưa có dữ liệu');
                        }
                        final total = data.fold<int>(0, (sum, e) => sum + (e['count'] as int));
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: data.map((e) {
                            final count = e['count'] as int;
                            final percent = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
                            return _TypeChip(
                              label: e['type'] as String,
                              count: count,
                              percent: percent,
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: MinhSizes.spaceBtwItems),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(MinhSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Số ca xử lý 7 ngày qua', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: MinhSizes.spaceBtwItems),
                      SizedBox(
                        height: 160,
                        child: Obx(() {
                          final data = controller.weeklyStats;
                          if (data.isEmpty) return const Text('Chưa có dữ liệu');
                          final max = data.fold<int>(0, (m, e) => (e['count'] as int) > m ? e['count'] as int : m);
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: data.map((e) {
                              final count = e['count'] as int;
                              return _WeeklyBar(
                                label: e['day'] as String,
                                value: count,
                                maxValue: max == 0 ? 1 : max,
                              );
                            }).toList(),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
  
  Widget _buildMapWidget(AdminDashboardController controller) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
        child: Obx(() {
          final pending = controller.mapSOS;
          
          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(16.0, 108.0), // Vietnam center
              initialZoom: 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: pending.map((sos) {
                  final lat = sos['lat'] as double;
                  final lng = sos['lng'] as double;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 36,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildRightColumn(AdminDashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent SOS
        _buildRecentSOSList(controller),
        const SizedBox(height: MinhSizes.spaceBtwSections),
        // Shelter Status
        _buildShelterStatus(controller),
      ],
    );
  }
  
  Widget _buildRecentSOSList(AdminDashboardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MinhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SOS Mới Nhất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => controller.navigateToSOS(),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: MinhSizes.spaceBtwItems),
            Obx(() {
              final sosList = controller.recentSOS;
              if (sosList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(MinhSizes.md),
                    child: Text('Không có SOS mới'),
                  ),
                );
              }
              
              return Column(
                children: sosList.map((sos) {
                  final severity = sos['severity'] as String;
                  Color severityColor = Colors.orange;
                  if (severity.contains('Khẩn cấp')) severityColor = Colors.red;
                  if (severity.contains('Cao')) severityColor = Colors.orange;
                  if (severity.contains('Thấp')) severityColor = Colors.green;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: severityColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => controller.navigateToSOS(),
                      child: Row(
                        children: [
                          Icon(Iconsax.danger, color: severityColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sos['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  sos['address'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShelterStatus(AdminDashboardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MinhSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trú ẩn cần chú ý',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: MinhSizes.spaceBtwItems),
            Obx(() {
              final shelters = controller.shelterStats;
              if (shelters.isEmpty) {
                return const Text(
                  'Tất cả điểm trú ẩn còn chỗ',
                  style: TextStyle(color: Colors.green),
                );
              }
              
              return Column(
                children: shelters.map((shelter) {
                  final percent = shelter['percent'] as int;
                  Color color = Colors.red;
                  if (percent < 90) color = Colors.orange;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.home, color: color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shelter['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(AdminDashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành động nhanh',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: MinhSizes.spaceBtwItems),
        Wrap(
          spacing: MinhSizes.spaceBtwItems,
          runSpacing: MinhSizes.spaceBtwItems,
          children: [
            _ActionButton(
              icon: Iconsax.notification,
              label: 'Phát cảnh báo',
              color: Colors.red,
              onTap: () => controller.showCreateAlertDialog(),
            ),
            _ActionButton(
              icon: Iconsax.task_square,
              label: 'Tạo nhiệm vụ',
              color: Colors.blue,
              onTap: () => controller.showCreateTaskDialog(),
            ),
            _ActionButton(
              icon: Iconsax.home_2,
              label: 'Thêm trú ẩn',
              color: Colors.green,
              onTap: () => controller.showAddShelterDialog(),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
      child: Container(
        width: (MediaQuery.of(context).size.width - MinhSizes.defaultSpace * 3) / 2,
        padding: const EdgeInsets.all(MinhSizes.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: MinhSizes.spaceBtwItems),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const _WeeklyBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    // Max bar height = 100, leaving space for text labels (60px total for labels)
    final barHeight = maxValue == 0 ? 0.0 : (value / maxValue) * 100;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 2),
        Container(
          width: 20,
          height: barHeight.clamp(0.0, 100.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final int count;
  final String percent;

  const _TypeChip({
    required this.label,
    required this.count,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Text('$count', style: const TextStyle(color: Colors.blue)),
          const SizedBox(width: 4),
          Text('($percent%)', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade100),
    );
  }
}

