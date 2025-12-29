import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_sos_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

/// Volunteer SOS Map Screen - Shows SOS requests on a map
/// Optimized with minimal Obx widgets for better rebuild performance
class VolunteerSOSMapScreen extends StatelessWidget {
  const VolunteerSOSMapScreen({super.key});

  static const _fallbackVNCenter = LatLng(12.24507, 109.19432);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerSOSMapController());

    return Scaffold(
      appBar: _buildAppBar(controller),
      body: Stack(
        children: [
          // Map - uses GetX for optimal rebuild
          _SOSMapView(controller: controller),

          // Filter buttons at top
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _FilterRow(controller: controller),
          ),

          // Stats card - separate Obx for independent rebuild
          const Positioned(
            top: 70,
            left: 10,
            child: _StatsCardObx(),
          ),

          // Legend - static, no rebuild needed
          const Positioned(
            bottom: 100,
            left: 10,
            child: _MapLegend(),
          ),

          // Selected request card - separate Obx
          const _SelectedRequestCardObx(),

          // Loading indicator - minimal Obx
          const _LoadingIndicatorObx(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(VolunteerSOSMapController controller) {
    return AppBar(
      // Title with Obx for filtered count only
      title: Obx(() => Text(
            'Yêu cầu SOS (${controller.filteredRequests.length})',
          )),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.refresh),
          onPressed: controller.refreshData,
          tooltip: 'Làm mới',
        ),
        IconButton(
          icon: const Icon(Iconsax.location),
          onPressed: controller.goToCurrentLocation,
          tooltip: 'Vị trí hiện tại',
        ),
      ],
    );
  }
}

/// Optimized map view with GetX builder
class _SOSMapView extends StatelessWidget {
  final VolunteerSOSMapController controller;

  const _SOSMapView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final position = controller.currentPosition.value;
      final markers = controller.sosMarkers;

      LatLng center = VolunteerSOSMapScreen._fallbackVNCenter;
      double zoom = 5.5;

      if (position != null) {
        center = LatLng(position.latitude, position.longitude);
        zoom = 12.0;
      } else if (markers.isNotEmpty) {
        center = markers.first.point;
        zoom = 10.0;
      }

      return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          onTap: (_, __) => controller.selectedRequest.value = null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              // Current location marker
              if (position != null)
                Marker(
                  key: const ValueKey('current_location'),
                  point: LatLng(position.latitude, position.longitude),
                  width: 50,
                  height: 50,
                  child: const _CurrentLocationMarker(),
                ),
              // SOS markers from cached list
              ...markers,
            ],
          ),
        ],
      );
    });
  }
}

/// Current location marker widget - const for optimization
class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Iconsax.location,
        color: Colors.blue,
        size: 32,
      ),
    );
  }
}

/// Stats card with its own Obx - isolates rebuild
class _StatsCardObx extends StatelessWidget {
  const _StatsCardObx();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerSOSMapController>();

    return Obx(() => _StatsCard(
          pendingCount: controller.pendingCount,
          inProgressCount: controller.inProgressCount,
        ));
  }
}

/// Selected request card with its own Obx
class _SelectedRequestCardObx extends StatelessWidget {
  const _SelectedRequestCardObx();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerSOSMapController>();

    return Obx(() {
      final request = controller.selectedRequest.value;
      if (request == null) return const SizedBox.shrink();

      return Positioned(
        bottom: 20,
        left: 10,
        right: 10,
        child: _SOSRequestCard(
          request: request,
          distance: controller.getDistanceToRequest(request),
          onAccept: () => controller.acceptRequest(request),
          onNavigate: () => controller.navigateToRequest(request),
          onClose: () => controller.selectedRequest.value = null,
        ),
      );
    });
  }
}

/// Loading indicator with minimal Obx
class _LoadingIndicatorObx extends StatelessWidget {
  const _LoadingIndicatorObx();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerSOSMapController>();

    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.black26,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    });
  }
}

/// Filter row widget
class _FilterRow extends StatelessWidget {
  final VolunteerSOSMapController controller;

  const _FilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedFilter.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.filter),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(value: 'pending', child: Text('Chờ hỗ trợ')),
                      DropdownMenuItem(value: 'urgent', child: Text('Khẩn cấp')),
                      DropdownMenuItem(value: 'nearby', child: Text('Gần nhất')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setFilter(value);
                      }
                    },
                  )),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Iconsax.sort),
              onPressed: () => _showSortOptions(context, controller),
              tooltip: 'Sắp xếp',
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context, VolunteerSOSMapController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Iconsax.location),
            title: const Text('Theo khoảng cách'),
            onTap: () {
              controller.sortBy('distance');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.clock),
            title: const Text('Theo thời gian'),
            onTap: () {
              controller.sortBy('time');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.danger),
            title: const Text('Theo mức độ khẩn cấp'),
            onTap: () {
              controller.sortBy('severity');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Stats card widget
class _StatsCard extends StatelessWidget {
  final int pendingCount;
  final int inProgressCount;

  const _StatsCard({
    required this.pendingCount,
    required this.inProgressCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Chờ hỗ trợ: $pendingCount'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Đang xử lý: $inProgressCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Map legend widget - const for optimization
class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chú giải:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const MinhMapLegendItem(
              icon: Iconsax.location,
              color: Colors.blue,
              label: 'Vị trí của bạn',
            ),
            const SizedBox(height: 4),
            MinhMapLegendItem(
              icon: Icons.sos,
              color: Colors.red.shade700,
              label: 'SOS chờ hỗ trợ',
            ),
            const SizedBox(height: 4),
            MinhMapLegendItem(
              icon: Icons.sos,
              color: Colors.orange.shade700,
              label: 'SOS đang xử lý',
            ),
          ],
        ),
      ),
    );
  }
}

/// SOS request card widget
class _SOSRequestCard extends StatelessWidget {
  final HelpRequestEntity request;
  final double? distance;
  final VoidCallback onAccept;
  final VoidCallback onNavigate;
  final VoidCallback onClose;

  const _SOSRequestCard({
    required this.request,
    this.distance,
    required this.onAccept,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == RequestStatus.pending;
    final statusColor = isPending ? Colors.red.shade700 : Colors.orange.shade700;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sos,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPending ? 'Chờ hỗ trợ' : 'Đang xử lý',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (distance != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Iconsax.location,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              request.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Address
            Row(
              children: [
                Icon(Iconsax.location, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.address,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Iconsax.routing, size: 18),
                    label: const Text('Chỉ đường'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isPending ? onAccept : null,
                    icon: const Icon(Iconsax.tick_circle, size: 18),
                    label: Text(isPending ? 'Nhận hỗ trợ' : 'Đã nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhColors.primary,
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
  }
}
