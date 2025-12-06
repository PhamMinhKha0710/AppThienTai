import 'package:cuutrobaolu/presentation/features/admin/controllers/help_controller.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/supporter_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupporterSheet extends StatelessWidget {
  const SupporterSheet({
    super.key,
    required this.supporter
  });

  final SupporterModel supporter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        children: [
          ListTile(
            title: Text(supporter.name, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(subtitle: Text('Capacity: ${supporter.capacity}')),
          ListTile(
            leading: Icon(Icons.location_pin),
            title: Text(
              'Vị trí: ${supporter.lat.toStringAsFixed(4)}, ${supporter.lng.toStringAsFixed(4)}',
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: supporter.available
                ? () async {
              final controller = Get.find<HelpController>();
              await controller.repository.reserveSupporter(supporter.id);
              Get.back();
            }
                : null,
            child: Text(supporter.available ? 'Reserve (simulate)' : 'Không khả dụng'),
          ),
        ],
      ),
    );
  }


}

