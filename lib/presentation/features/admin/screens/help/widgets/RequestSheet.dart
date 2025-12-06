import 'package:cuutrobaolu/presentation/features/admin/controllers/help_controller.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReQuestsheet extends StatelessWidget {
  const ReQuestsheet({
    super.key,
    required this.request,

  });

  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        children: [
          ListTile(
            title: Text(request.title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(subtitle: Text(request.description)),
          ListTile(
            leading: Icon(Icons.location_pin),
            title: Text(
              'Vị trí: ${request.lat.toStringAsFixed(4)}, ${request.lng.toStringAsFixed(4)}',
            ),
          ),
          ListTile(leading: Icon(Icons.phone), title: Text(request.contact)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final c = Get.find<HelpController>();
              final sels = c.selectedSupporters;
              if (sels.isEmpty) {
                Get.snackbar(
                  'Chưa chọn',
                  'Không có supporter nào được chọn',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              showDialog(
                context: Get.context!,
                builder: (_) => AlertDialog(
                  title: Text('Supporters đã chọn'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: sels
                        .map(
                          (s) => ListTile(
                        title: Text(s.name),
                        subtitle: Text('Capacity: ${s.capacity}'),
                      ),
                    )
                        .toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(Get.context!),
                      child: Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Xem supporters được gợi ý'),
          ),
        ],
      ),
    );
  }


}

