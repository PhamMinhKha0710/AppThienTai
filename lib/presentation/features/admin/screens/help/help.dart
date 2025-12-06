import 'dart:async';

import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';

import 'package:cuutrobaolu/core/widgets/storms/storm_advanced_layer.dart';
import 'package:cuutrobaolu/core/widgets/storms/storm_layer.dart';
import 'package:cuutrobaolu/core/widgets/storms/storm_map.dart';

import 'package:cuutrobaolu/presentation/features/admin/controllers/help_controller.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/help/widgets/RequestSheet.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/help/widgets/SupporterSheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' hide Marker;


class HelpAdminScreen extends StatelessWidget {
  final _searchController = TextEditingController();
  final _debounceTimer = Rx<Timer?>(null);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HelpController());

    return Scaffold(
      appBar: MinhAppbar(title: Text("Cứu Trợ"), showBackArrow: true,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ctrl.clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _debounceTimer.value?.cancel();
                _debounceTimer.value = Timer(Duration(milliseconds: 500), () {
                  if (value.isNotEmpty) {
                    ctrl.searchLocation(value);
                  } else {
                    ctrl.clearSearch();
                  }
                });
              },
            ),
          ),
          // Search Results List
          Obx(() {
            if (ctrl.searchResults.isNotEmpty) {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: ctrl.searchResults.length,
                  itemBuilder: (context, index) {
                    final result = ctrl.searchResults[index];

                    // Lấy và định dạng tọa độ
                    final latStr = result['lat']?.toString() ?? '0';
                    final lonStr = result['lon']?.toString() ?? '0';
                    final lat = double.tryParse(latStr) ?? 0.0;
                    final lon = double.tryParse(lonStr) ?? 0.0;
                    final formattedLat = lat.toStringAsFixed(4);
                    final formattedLon = lon.toStringAsFixed(4);

                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(
                        result['display_name']?.toString() ?? 'Không có tên',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('$formattedLat, $formattedLon'),
                      onTap: () {
                        ctrl.moveToLocation(LatLng(lat, lon));
                        _searchController.text =
                            result['display_name']?.toString() ?? '';
                        ctrl.searchResults.clear();
                      },
                    );
                  },
                ),
              );
            }
            return SizedBox.shrink();
          }),
          // Map
          Expanded(
            child: Obx(() {
              final markers = <Marker>[];
              final stormMaps = <StormMap>[];
              final stormLayers = <StormLayer>[];
              var stormCenter = LatLng(16.05, 108.2);

              // help requests - red
              for (var r in ctrl.requests) {

                markers.add(
                  Marker(
                    point: LatLng(r.lat, r.lng),
                    width: 42,
                    height: 42,
                    child: GestureDetector(
                      onTap: () {
                        ctrl.selectRequest(r);
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => ReQuestsheet( request: r,),
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        size: 38,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }

              // supporters - green or gray if not available
              for (var s in ctrl.supporters) {
                final color = s.available ? Colors.green : Colors.grey;
                markers.add(
                  Marker(
                    point: LatLng(s.lat, s.lng),
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => SupporterSheet(supporter: s,),
                      ),
                      child: Icon(
                        Icons.volunteer_activism,
                        size: 30,
                        color: color,
                      ),
                    ),
                  ),
                );
              }

              // Thêm marker cho vị trí tìm kiếm (màu xanh dương)
              if (ctrl.searchLocationMarker.value != null) {
                markers.add(
                  Marker(
                    point: ctrl.searchLocationMarker.value!,
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.location_pin,
                      size: 45,
                      color: Colors.blue,
                    ),
                  ),
                );
              }

              // storm map - blue
              for (var st in ctrl.supporters) {
                stormMaps.add(
                  StormMap(
                    stormCenter: LatLng(st.lat, st.lng),
                    eyeRadiusKm: 25,
                    windRadiusKm: 180,
                    track: [
                      LatLng(10.0, 108.0),
                      LatLng(11.0, 108.5),
                      LatLng(12.0, 109.0),
                    ],
                  ),
                );
              }

              // storm layer - blue
              for (var st in ctrl.supporters) {
                stormCenter = LatLng(st.lat, st.lng);
                break;
              }

              // polylines: from selected request to selected supporters
              final polylines = <Polyline>[];
              final selReq = ctrl.selectedRequest.value;
              if (selReq != null) {
                for (var s in ctrl.selectedSupporters) {
                  polylines.add(
                    Polyline(
                      points: [
                        LatLng(selReq.lat, selReq.lng),
                        LatLng(s.lat, s.lng),
                      ],
                      strokeWidth: 3.0,
                      color: Colors.orange.withOpacity(0.7),
                    ),
                  );
                }
              }

              return FlutterMap(
                options: MapOptions(
                  initialCenter: ctrl.mapCenter.value,
                  initialZoom: ctrl.mapZoom.value,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onMapReady: () {
                    // Có thể thêm xử lý khi map ready
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  ...stormLayers,
                  StormAdvancedLayer(
                    center: stormCenter,
                    eyeRadiusKm: 25,
                    windRadiusKm: 150,
                    cloudSvgAsset: "assets/svgs/cloud/cloud_swirl.svg",
                    radarAsset: "assets/image/radar/radar_overlay.png",
                    track: [
                      LatLng(14.5, 110.0),
                      LatLng(15.0, 109.0),
                      LatLng(15.5, 108.5),
                      LatLng(16.05, 108.2),
                      LatLng(17.0, 107.6),
                    ],
                    trackDuration: Duration(seconds: 25),
                  ),
                  if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),
                ],
              );
            }),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Nút xóa marker tìm kiếm
          if (Get.find<HelpController>().searchLocationMarker.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Get.find<HelpController>().clearSearchMarker();
                },
                child: Icon(Icons.clear),
                backgroundColor: Colors.red,
                mini: true,
              ),
            ),
          // Nút gán nhà hỗ trợ
          FloatingActionButton.extended(
            onPressed: () async {
              await ctrl.assignSelectedSupporters();
              Get.snackbar(
                'Đã gửi yêu cầu',
                'Đã reserve supporter (nếu đủ capacity)',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            label: Text('Gán nhà hỗ trợ'),
            icon: Icon(Icons.thumb_up),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer.value?.cancel();
  }




}

