import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/core/widgets/buttons/MinhShortcutButton.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhAlertCard.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/sos/victim_sos_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/map/victim_map_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/receive/victim_receive_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_home_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/NavigationVictimController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VictimHomeScreen extends StatelessWidget {
  const VictimHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimHomeController());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header với Appbar
              MinhPrimaryHeaderContainer(
                child: Column(
                  children: [
                    MinhAppbar(
                      title: Text(
                        "Hỗ trợ Thiên tai",
                        style: Theme.of(context).textTheme.headlineMedium!.apply(
                          color: MinhColors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: MinhSizes.spaceBtwItems),
                  ],
                ),
              ),

              // Mini-map (40% màn hình)
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                margin: EdgeInsets.all(MinhSizes.defaultSpace),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                  child: Obx(() {
                    final position = controller.currentPosition.value;
                    if (position == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: MinhSizes.spaceBtwItems),
                            Text("Đang lấy vị trí..."),
                          ],
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(position.latitude, position.longitude),
                            initialZoom: 13.0,
                            onTap: (tapPosition, point) {
                              Get.to(() => VictimMapScreen());
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                // Vị trí hiện tại
                                Marker(
                                  point: LatLng(position.latitude, position.longitude),
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Iconsax.location,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                                // Yêu cầu cứu trợ của user
                                ...controller.myRequests.map((req) {
                                  Color markerColor = Colors.orange;
                                  IconData markerIcon = Iconsax.clock;
                                  
                                  switch (req.status) {
                                    case RequestStatus.pending:
                                      markerColor = Colors.orange;
                                      markerIcon = Iconsax.clock;
                                      break;
                                    case RequestStatus.inProgress:
                                      markerColor = Colors.blue;
                                      markerIcon = Iconsax.refresh;
                                      break;
                                    case RequestStatus.completed:
                                      markerColor = Colors.green;
                                      markerIcon = Iconsax.tick_circle;
                                      break;
                                    case RequestStatus.cancelled:
                                      markerColor = Colors.grey;
                                      markerIcon = Iconsax.close_circle;
                                      break;
                                  }
                                  
                                  return Marker(
                                    point: LatLng(req.lat, req.lng),
                                    width: 45,
                                    height: 45,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(() => VictimMapScreen());
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: markerColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: markerColor.withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          markerIcon,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: ElevatedButton.icon(
                            onPressed: () => Get.to(() => VictimMapScreen()),
                            icon: Icon(Iconsax.map),
                            label: Text("Xem bản đồ đầy đủ"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MinhColors.primary,
                              foregroundColor: MinhColors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Nút Cần giúp / Cần nhận nổi bật
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(MinhSizes.defaultSpace),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.warning_2,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: MinhSizes.spaceBtwItems),
                      Text(
                        "Cần cứu trợ khẩn cấp?",
                        style: Theme.of(context).textTheme.headlineSmall?.apply(
                          color: Colors.white,
                          fontWeightDelta: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MinhSizes.spaceBtwItems / 2),
                      Text(
                        "Gửi yêu cầu SOS để nhận hỗ trợ ngay lập tức",
                        style: Theme.of(context).textTheme.bodyMedium?.apply(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MinhSizes.spaceBtwItems),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Get.to(() => VictimSosScreen()),
                              icon: Icon(Iconsax.warning_2, size: 20),
                              label: Text("Cần giúp"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: MinhSizes.spaceBtwItems),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.to(() => const VictimReceiveScreen());
                              },
                              icon: Icon(Iconsax.receive_square, size: 20),
                              label: Text("Cần nhận"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white, width: 2),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: MinhSizes.spaceBtwSections),

              // Cảnh báo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MinhSectionHeading(
                      title: "Cảnh báo gần đây",
                      showActionButton: true,
                      buttonTitle: "Xem tất cả",
                      onPressed: () {
                        NavigationVictimController.selectedIndex.value = 2;
                      },
                    ),
                    SizedBox(height: MinhSizes.spaceBtwItems),
                    Obx(() {
                      final alerts = controller.recentAlerts;
                      if (alerts.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(MinhSizes.defaultSpace),
                            child: Text("Không có cảnh báo nào"),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return Container(
                              width: 300,
                              margin: EdgeInsets.only(right: MinhSizes.spaceBtwItems),
                              child: MinhAlertCard(
                                alert: alert,
                                showActions: false,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: MinhSizes.spaceBtwSections),

              // Shortcut buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MinhSectionHeading(
                      title: "Hỗ trợ nhanh",
                      showActionButton: false,
                    ),
                    SizedBox(height: MinhSizes.spaceBtwItems),
                    Row(
                      children: [
                        Expanded(
                          child: MinhShortcutButton(
                            icon: Iconsax.home_2,
                            label: "Điểm trú ẩn",
                            color: Colors.blue,
                            onTap: () {
                              Get.to(() => VictimMapScreen());
                            },
                          ),
                        ),
                        SizedBox(width: MinhSizes.spaceBtwItems),
                        Expanded(
                          child: MinhShortcutButton(
                            icon: Iconsax.document_text,
                            label: "Hướng dẫn",
                            color: Colors.green,
                            onTap: () {
                              NavigationVictimController.selectedIndex.value = 3;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: MinhSizes.spaceBtwSections),

              // Dự báo ML
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                child: Obx(() {
                  final forecast = controller.forecast.value;
                  if (forecast == null) return SizedBox.shrink();
                  
                  return Container(
                    padding: EdgeInsets.all(MinhSizes.defaultSpace),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.withOpacity(0.3),
                          Colors.red.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.warning_2, color: Colors.red, size: 40),
                        SizedBox(width: MinhSizes.spaceBtwItems),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dự báo ngập",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                forecast,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      // FAB đã được thay thế bằng nút nổi bật ở trên
    );
  }
}


