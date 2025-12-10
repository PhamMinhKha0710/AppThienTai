import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Card hiển thị cảnh báo thiên tai
class MinhAlertCard extends StatelessWidget {
  const MinhAlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.showActions = true,
  });

  final Map<String, dynamic> alert;
  final VoidCallback? onTap;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final isHighSeverity = alert['severity'] == 'high' || alert['severity'] == 'urgent';
    final severityColor = isHighSeverity ? Colors.red : Colors.orange;
    
    return Card(
      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      color: severityColor.withOpacity(0.1),
      child: InkWell(
        onTap: onTap ?? () => _showAlertDetails(context, alert, severityColor),
        child: Padding(
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(MinhSizes.sm),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
                ),
                child: Icon(
                  Iconsax.warning_2,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: MinhSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'] ?? 'Cảnh báo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: MinhSizes.spaceBtwItems / 2),
                    Text(
                      alert['description'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (alert['time'] != null) ...[
                      SizedBox(height: MinhSizes.spaceBtwItems / 2),
                      Text(
                        alert['time'],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDetails(BuildContext context, Map<String, dynamic> alert, Color severityColor) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.warning_2, color: severityColor),
            SizedBox(width: MinhSizes.spaceBtwItems / 2),
            Expanded(child: Text(alert['title'] ?? 'Cảnh báo')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert['description'] ?? ''),
            if (alert['time'] != null) ...[
              SizedBox(height: MinhSizes.spaceBtwItems),
              Text(
                "Thời gian: ${alert['time']}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: showActions
            ? [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Đóng'),
                ),
                if (alert['location'] != null)
                  TextButton(
                    onPressed: () {
                      Get.back();
                      // TODO: Navigate to map
                    },
                    child: Text('Xem trên bản đồ'),
                  ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    // TODO: Show safety guide
                  },
                  child: Text('Hướng dẫn xử lý'),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Đóng'),
                ),
              ],
      ),
    );
  }
}

