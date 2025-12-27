import 'package:cuutrobaolu/core/constants/exports.dart';
import 'package:cuutrobaolu/presentation/features/chat/controller/shelters_nearest_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';

class ItemShelter extends StatelessWidget {
  const ItemShelter({
    super.key,
    required this.shelter,
    required this.controller,
  });

  final ShelterEntity shelter;
  final SheltersNearestController controller;

  @override
  Widget build(BuildContext context) {
    final isAvailable = !shelter.isFull;
    final availableSlots = shelter.availableSlots;
    final occupancyPercent = shelter.capacity > 0
        ? (shelter.currentOccupancy / shelter.capacity * 100).round()
        : 0;

    return Card(
      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      child: Padding(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shelter.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MinhSizes.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Còn $availableSlots chỗ' : 'Đã đầy',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),

            // Address
            Row(
              children: [
                Icon(Iconsax.location, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shelter.address,
                    style: TextStyle(color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),

            // Distance and capacity
            Row(
              children: [
                Icon(Iconsax.route_square, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Obx(() {
                  final distanceText = controller.getShelterDistanceText(shelter.id);
                  return Text(
                    distanceText,
                    style: TextStyle(
                      color: MinhColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
                Spacer(),
                Icon(Iconsax.people, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(
                  '${shelter.currentOccupancy}/${shelter.capacity} ($occupancyPercent%)',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),

            // Occupancy progress bar
            LinearProgressIndicator(
              value: shelter.capacity > 0
                  ? shelter.currentOccupancy / shelter.capacity
                  : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancyPercent > 80 ? Colors.red :
                occupancyPercent > 50 ? Colors.orange : Colors.green,
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // Amenities (if any)
            if (shelter.amenities != null && shelter.amenities!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiện ích:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: shelter.amenities!.map((amenity) {
                      return Chip(
                        label: Text(
                          _getAmenityText(amenity),
                          style: TextStyle(fontSize: 11),
                        ),
                        backgroundColor: MinhColors.primary.withOpacity(0.1),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                ],
              ),

            // Contact info
            if (shelter.contactPhone != null || shelter.contactEmail != null)
              Row(
                children: [
                  if (shelter.contactPhone != null) ...[
                    Icon(Iconsax.call, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      shelter.contactPhone!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    SizedBox(width: 16),
                  ],
                  if (shelter.contactEmail != null) ...[
                    Icon(Iconsax.sms, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      shelter.contactEmail!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ],
              ),
            SizedBox(height: MinhSizes.spaceBtwItems),

            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Iconsax.direct, size: 16),
                  label: Text('Chỉ đường'),
                  onPressed: () => controller.navigateToShelter(shelter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MinhColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: Icon(Iconsax.map, size: 16),
                  label: Text('Xem bản đồ'),
                  onPressed: () => controller.viewShelterOnMap(shelter),
                ),
                Spacer(),
                if (shelter.distributionTime != null)
                  IconButton(
                    icon: Icon(Iconsax.clock, size: 20),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Thời gian phân phát'),
                          content: Text('${shelter.distributionTime}'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Đóng'),
                            ),
                          ],
                        ),
                      );
                    },
                    tooltip: 'Thời gian phân phát',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getAmenityText(String amenity) {
    switch (amenity) {
      case 'water': return 'Nước uống';
      case 'food': return 'Thực phẩm';
      case 'medical': return 'Y tế';
      case 'electricity': return 'Điện';
      case 'wifi': return 'WiFi';
      case 'bathroom': return 'Nhà vệ sinh';
      default: return amenity;
    }
  }
}