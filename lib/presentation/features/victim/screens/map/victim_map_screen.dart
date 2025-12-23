import 'package:cuutrobaolu/core/widgets/map/MinhMapLegendItem.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_map_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_receive_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_sos_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class VictimMapScreen extends StatelessWidget {
  const VictimMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimMapController());
    const fallbackVNCenter = LatLng(12.24507, 109.19432); // Nha Trang, VN

    final receiveCtrl = Get.put(VictimReceiveController());
    final sosCtrl = Get.put(VictimSosController());

    // Ensure distribution points are loaded
    receiveCtrl.loadData();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bản đồ thiên tai"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshMarkers(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          Obx(() {
            final position = controller.currentPosition.value;
            // Ưu tiên: vị trí hiện tại -> điểm thiên tai đầu tiên -> fallback VN
            LatLng center = fallbackVNCenter;
            double zoom = 5.5;

            if (position != null) {
              center = LatLng(position.latitude, position.longitude);
              zoom = 13.0;
            } else if (controller.disasterMarkers.isNotEmpty) {
              center = controller.disasterMarkers.first.point;
              zoom = 8.5;
            }

            return FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onLongPress: (tapPosition, point) {
                  // Báo cáo thiên tai mới
                  controller.showReportDialog(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Optional radar/weather overlay
                Obx(() {
                  final url = controller.radarImageUrl.value;
                  final bounds = controller.radarBounds.value;
                  if (url == null || bounds == null) return const SizedBox.shrink();
                  return OverlayImageLayer(
                    overlayImages: [
                      OverlayImage(
                        bounds: bounds,
                        imageProvider: NetworkImage(url),
                        opacity: 0.6,
                      ),
                    ],
                  );
                }),
                // OpenWeatherMap tile overlay
                Obx(() {
                  if (!controller.showOwmTiles.value) return const SizedBox.shrink();
                  final template = controller.getOwmTileUrlTemplate();
                  if (template == null) return const SizedBox.shrink();
                  return Opacity(
                    opacity: controller.owmTileOpacity.value,
                    child: TileLayer(
                      urlTemplate: template,
                    ),
                  );
                }),
                // Markers cho thiên tai
                MarkerLayer(
                  markers: [
                    if (position != null)
                      // Vị trí hiện tại
                      Marker(
                        point: LatLng(position.latitude, position.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(Iconsax.location, color: Colors.blue, size: 40),
                      ),
                    // Yêu cầu cứu trợ của chính user (ưu tiên hiển thị)
                    ...controller.myRequestMarkers.map((marker) => marker),
                    // Các điểm thiên tai
                    ...controller.disasterMarkers.map((marker) => marker),
                    // Điểm trú ẩn
                    ...controller.shelterMarkers.map((marker) => marker),
                  ],
                ),
                // Distribution / Donation points (nearby supply distribution)
                Obx(() {
                  final pts = receiveCtrl.nearbyDistributionPoints;
                  if (pts.isEmpty) return const SizedBox.shrink();
                  return MarkerLayer(
                    markers: pts.map((p) {
                      final lat = p['lat'] as double?;
                      final lng = p['lng'] as double?;
                      if (lat == null || lng == null) return Marker(point: LatLng(0,0), width: 0, height: 0, child: const SizedBox.shrink());
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () {
                            // show bottom sheet with distribution info
                            Get.bottomSheet(Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_shipping, size: 28, color: Colors.green),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(p['name'] ?? 'Điểm phân phối', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if ((p['address'] ?? '').toString().isNotEmpty) Text(p['address'], style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text('Sức chứa: ${p['capacity'] ?? '-'}  -  Còn trống: ${p['available'] ?? '-'}'),
                                  const SizedBox(height: 8),
                                  Text('Thời gian phân phối: ${p['distributionTime'] ?? '-'}'),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Get.back();
                                          await receiveCtrl.registerForDistribution(p['id'], p);
                                        },
                                        child: const Text('Đăng ký nhận'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Center(child: Icon(Icons.local_shipping, color: Colors.white, size: 24)),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                // Polyline routes
                Obx(() {
                  if (controller.routePolylines.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolylineLayer(
                    polylines: controller.routePolylines,
                  );
                }),
                // Hazard polygons (storms, flood zones, landslides)
                Obx(() {
                  if (!controller.showHazards.value || controller.hazardPolygons.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolygonLayer(polygons: controller.hazardPolygons);
                }),
              ],
            );
          }),

          // Hazard banner & guidance
          Obx(() {
            if (!controller.showHazardBanner.value) return const SizedBox.shrink();
            final text = controller.hazardSummary.value ?? 'Cảnh báo nguy hiểm';
            return Positioned(
              top: 70,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Iconsax.danger, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent),
                        onPressed: () {
                          // open guidance modal
                          Get.dialog(Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Hướng dẫn an toàn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    const Text('1. Ở yên tại vị trí an toàn nếu có thể.'),
                                    const SizedBox(height: 8),
                                    const Text('2. Nếu cần di chuyển, tìm chỗ trú ẩn gần nhất bằng nút "Tìm trú ẩn".'),
                                    const SizedBox(height: 8),
                                    const Text('3. Tránh khu vực lũ/đường trơn, không đi qua vùng ngập nước.'),
                                    const SizedBox(height: 8),
                                    const Text('4. Liên hệ dịch vụ khẩn cấp nếu cần thiết.'),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // open distribution panel
                                            controller.toggleDistributionPanel();
                                            Get.back();
                                          },
                                          child: const Text('Tìm trú ẩn'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            // call emergency number
                                            final uri = Uri(scheme: 'tel', path: '112');
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(uri);
                                            } else {
                                              Get.snackbar('Lỗi', 'Không thể gọi số khẩn cấp trên thiết bị này');
                                            }
                                          },
                                          child: const Text('Gọi SOS'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
                        },
                        child: const Text('Hướng dẫn', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Controls ở trên
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(MinhSizes.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tìm điểm trú ẩn...",
                          prefixIcon: Icon(Iconsax.search_normal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                          ),
                        ),
                        onChanged: (value) => controller.searchShelter(value),
                      ),
                    ),
                    SizedBox(width: MinhSizes.spaceBtwItems),
                    PopupMenuButton<String>(
                      icon: Icon(Iconsax.filter),
                      onSelected: (value) => controller.filterDisasterType(value),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'all', child: Text('Tất cả')),
                        PopupMenuItem(value: 'flood', child: Text('Lũ lụt')),
                        PopupMenuItem(value: 'storm', child: Text('Bão')),
                        PopupMenuItem(value: 'landslide', child: Text('Sạt lở')),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Distribution list toggle
                    IconButton(
                      tooltip: 'Danh sách điểm phân phối',
                      icon: const Icon(Icons.list),
                      onPressed: () => controller.toggleDistributionPanel(),
                    ),
                    const SizedBox(width: 8),
                    // Weather/Overlay settings button
                    IconButton(
                      tooltip: 'Radar / Thời tiết',
                      icon: const Icon(Icons.cloud),
                      onPressed: () {
                        final apiController = TextEditingController(text: controller.owmApiKey.value);
                        String selectedLayer = controller.selectedOwmLayer.value;
                        double opacity = controller.owmTileOpacity.value;
                        bool showTiles = controller.showOwmTiles.value;

                        Get.dialog(Dialog(
                          child: StatefulBuilder(builder: (context, setState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              width: 360,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Cấu hình Overlay thời tiết', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: apiController,
                                    decoration: const InputDecoration(
                                      labelText: 'OpenWeatherMap API key',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Layer: '),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedLayer,
                                          items: controller.availableOwmLayers.map((layer) {
                                            return DropdownMenuItem(value: layer, child: Text(layer));
                                          }).toList(),
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() => selectedLayer = v);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Hiển thị'),
                                      const Spacer(),
                                      Switch.adaptive(
                                        value: showTiles,
                                        onChanged: (v) => setState(() => showTiles = v),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('Độ mờ'),
                                      Expanded(
                                        child: Slider(
                                          value: opacity,
                                          min: 0.0,
                                          max: 1.0,
                                          divisions: 10,
                                          onChanged: (v) => setState(() => opacity = v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          controller.setOwmApiKey(apiController.text.trim());
                                          controller.setSelectedOwmLayer(selectedLayer);
                                          controller.setOwmOpacity(opacity);
                                          controller.toggleShowOwmTiles(showTiles);
                                          Get.back();
                                        },
                                        child: const Text('Lưu'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Legend ở dưới
          Positioned(
            bottom: 20,
            left: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(MinhSizes.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MinhMapLegendItem(icon: Iconsax.location, color: Colors.blue, label: "Vị trí bạn"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Iconsax.warning_2, color: Colors.orange, label: "Yêu cầu của tôi"),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Iconsax.danger, color: Colors.red, label: "Thiên tai"),
                    SizedBox(height: 4),
                    // Toggle hiển thị vùng nguy hiểm
                    Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Hiện vùng nguy hiểm', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: controller.showHazards.value,
                          onChanged: (v) => controller.showHazards.value = v,
                        ),
                      ],
                    )),
                    SizedBox(height: 4),
                    MinhMapLegendItem(icon: Iconsax.home_2, color: Colors.green, label: "Điểm trú ẩn"),
                  ],
                ),
              ),
            ),
          ),

          // Right-side distribution list panel
          Obx(() {
            if (!controller.showDistributionPanel.value) return const SizedBox.shrink();
            final pts = receiveCtrl.filteredPoints;
            return Positioned(
              top: 80,
              right: 0,
              bottom: 80,
              width: 320,
              child: Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Expanded(child: Text('Điểm phân phối gần', style: TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => controller.toggleDistributionPanel(),
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: pts.isEmpty
                          ? const Center(child: Text('Không có điểm phân phối'))
                          : ListView.builder(
                              itemCount: pts.length,
                              itemBuilder: (context, i) {
                                final p = pts[i];
                                final items = (p['items'] as List<dynamic>?)?.cast<String>() ?? <String>[];
                                final availPercent = (p['availPercent'] as int?) ?? 0;
                                Color availColor = Colors.green;
                                if (availPercent < 20) {
                                  availColor = Colors.red;
                                } else if (availPercent < 50) {
                                  availColor = Colors.orange;
                                }

                                final eta = (p['etaMinutes'] as int?) ?? -1;
                                final etaText = eta > 0 ? 'ETA: ${eta}m' : '';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: availColor,
                                    child: Text('${p['available'] ?? 0}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text(p['name'] ?? 'Điểm phân phối'),
                                  subtitle: Text(items.isNotEmpty ? items.join(', ') : (p['address'] ?? '')),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (etaText.isNotEmpty) Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(etaText, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                      ),
                                      IconButton(
                                        tooltip: 'Hiển thị trên bản đồ',
                                        icon: const Icon(Icons.map),
                                        onPressed: () {
                                          final lat = p['lat'] as double?;
                                          final lng = p['lng'] as double?;
                                          if (lat != null && lng != null) {
                                            controller.focusOnLocation(LatLng(lat, lng));
                                          }
                                        },
                                      ),
                                      IconButton(
                                        tooltip: 'Chỉ đường',
                                        icon: const Icon(Icons.directions),
                                        onPressed: () {
                                          final lat = p['lat'] as double?;
                                          final lng = p['lng'] as double?;
                                          if (lat != null && lng != null) {
                                            controller.findRouteTo(LatLng(lat, lng));
                                            controller.focusOnLocation(LatLng(lat, lng));
                                            controller.toggleDistributionPanel();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // open detailed bottom sheet (reuse marker tap behavior)
                                    final lat = p['lat'] as double?;
                                    final lng = p['lng'] as double?;
                                    if (lat != null && lng != null) {
                                      // open bottom sheet same as marker tap
                                      Get.bottomSheet(Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.local_shipping, size: 28, color: Colors.green),
                                                const SizedBox(width: 12),
                                                Expanded(child: Text(p['name'] ?? 'Điểm phân phối', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            if ((p['address'] ?? '').toString().isNotEmpty) Text(p['address'], style: const TextStyle(color: Colors.grey)),
                                            const SizedBox(height: 8),
                                            Text('Sức chứa: ${p['capacity'] ?? '-'}  -  Còn trống: ${p['available'] ?? '-'}'),
                                            const SizedBox(height: 8),
                                            Text('Thời gian phân phối: ${p['distributionTime'] ?? '-'}'),
                                            const SizedBox(height: 12),
                                            if (items.isNotEmpty) ...[
                                              const Text('Mặt hàng phân phối:', style: TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 6),
                                              for (final it in items) Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                child: Text('- $it'),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Get.back();
                                                    await receiveCtrl.registerForDistribution(p['id'], p);
                                                  },
                                                  child: const Text('Đăng ký nhận'),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    controller.findRouteTo(LatLng(p['lat'], p['lng']));
                                                    controller.focusOnLocation(LatLng(p['lat'], p['lng']));
                                                    Get.back();
                                                  },
                                                  child: const Text('Chỉ đường'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Button tìm đường
          Positioned(
            bottom: 20,
            right: 10,
            child: Obx(() {
              if (controller.selectedShelter.value == null) {
                return SizedBox.shrink();
              }
              return FloatingActionButton.extended(
                onPressed: () => controller.findRoute(),
                backgroundColor: MinhColors.primary,
                icon: Icon(Iconsax.location),
                label: Text("Tìm đường"),
              );
            }),
          ),
          // Quick SOS button (fast path)
          Positioned(
            bottom: 90,
            left: 12,
            child: Obx(() {
              return FloatingActionButton.extended(
                heroTag: 'quick_sos',
                backgroundColor: Colors.redAccent,
                icon: sosCtrl.isSubmitting.value ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Iconsax.danger, color: Colors.white),
                label: Text(sosCtrl.isSubmitting.value ? 'Đang gửi...' : 'Gửi SOS', style: const TextStyle(color: Colors.white)),
                onPressed: sosCtrl.isSubmitting.value ? null : () {
                  // Show quick confirm dialog with nearest shelter suggestion
                  final nearest = receiveCtrl.nearbyDistributionPoints.isNotEmpty ? receiveCtrl.nearbyDistributionPoints.first : null;
                  final shelterName = nearest != null ? (nearest['name'] ?? '') : 'Không có trú ẩn gần';
                  Get.dialog(AlertDialog(
                    title: const Text('Gửi SOS nhanh'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bạn sắp gửi yêu cầu SOS khẩn cấp với thông tin tối thiểu.'),
                        const SizedBox(height: 8),
                        Text('Trú ẩn gợi ý: $shelterName'),
                        const SizedBox(height: 8),
                        const Text('Bạn có muốn tiếp tục gửi ngay?'),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
                      ElevatedButton(onPressed: () async {
                        Get.back();
                        // Prefill description with minimal info
                        final desc = 'SOS Khẩn cấp - Cần hỗ trợ ngay. Gửi từ ứng dụng.';
                        sosCtrl.descriptionController.text = desc;
                        // Ensure we have location
                        await sosCtrl.getCurrentLocation();
                        // Optionally attach nearest shelter info to description
                        if (nearest != null) {
                          sosCtrl.descriptionController.text = '$desc\\nTrú ẩn gợi ý: ${nearest['name']} - ${nearest['address'] ?? ''}';
                        }
                        // Submit SOS
                        await sosCtrl.submitSOS();
                        // After sending, open distribution panel to show shelters
                        controller.toggleDistributionPanel();
                      }, child: const Text('Gửi ngay')),
                    ],
                  ));
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}


