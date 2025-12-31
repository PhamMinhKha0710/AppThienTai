
import 'package:cuutrobaolu/core/constants/exports.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_tasks_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ItemTask extends StatelessWidget {
  const ItemTask({
    super.key,
    required this.task,
    required this.status,
    required this.controller,
  });

  final Map<String, dynamic> task;
  final dynamic status;
  final VolunteerTasksController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      child: Padding(
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task['title'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: MinhSizes.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'completed'
                        ? Colors.green.withOpacity(0.15)
                        : status == 'accepted'
                        ? Colors.orange.withOpacity(0.15)
                        : MinhColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'completed'
                        ? 'Hoàn thành'
                        : status == 'accepted'
                        ? 'Đang làm'
                        : 'Chờ nhận',
                    style: TextStyle(
                      color: status == 'completed'
                          ? Colors.green
                          : status == 'accepted'
                          ? Colors.orange
                          : MinhColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),
            Text(task['desc'] ?? ''),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),
            Row(
              children: [
                const Icon(Iconsax.location, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task['distanceText'] ?? 'Đang tính...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.onAccept(task),
                      child: const Text('Nhận nhiệm vụ'),
                    ),
                  ),
                if (status == 'accepted')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.onComplete(task),
                      child: const Text('Hoàn thành'),
                    ),
                  ),
                if (status == 'pending' || status == 'accepted')
                  const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Iconsax.map),
                    label: const Text('Xem bản đồ'),
                    onPressed: () => controller.viewTaskOnMap(task),
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
