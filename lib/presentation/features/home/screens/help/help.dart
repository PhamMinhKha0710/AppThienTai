

// Cách 1 sử dụng stfull

import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/loaders/circular_loader.dart';
import 'package:cuutrobaolu/presentation/features/admin/controllers/help_controller.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/help/help.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/address/widgets/MinhSingleAddress.dart';
import 'package:cuutrobaolu/presentation/features/home/screens/help/create_request_screen.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HelpController());
    final isDark = MinhHelperFunctions.isDarkMode(context);
    
    // Load requests when screen is built
    controller.loadRequestHelpForUserCurrent();

    return Scaffold(
      appBar: MinhAppbar(title: Text("Cứu Trợ Báo Lũ")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          child: Obx(() {
            final requests = controller.requestsUserCurrent;

            if (controller.isLoading.value) {
              return MinhCircularLoader();
            }

            if (requests.isEmpty) {
              return Center(
                child: Text(
                  "Bạn chưa có yêu cầu nào! ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            } else {
              return Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var i in requests) ...[
                    MinhSingleAddress(
                      selectAddress: i.status.toJson() == RequestStatus.completed.toJson(), // hoặc false
                      name: i.type.toJson(),
                      phone: i.contact,
                      address: i.address,
                      description: i.description,
                      title: i.title,
                      date: i.createdAt,
                      status: i.status,

                    ),
                  ],
                ],
              );
            }
          }),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              Get.to(() => HelpAdminScreen());
            },
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.black,
            foregroundColor: isDark ? Colors.white : Colors.white,
            child: const Icon(Iconsax.map), // icon bản đồ
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: "btn2",
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.black,
            foregroundColor: isDark ? Colors.white : Colors.white,
            onPressed: () {
              Get.to(() => CreateRequestScreen());
            },
            child: const Icon(Iconsax.message_question), // icon help
          ),
        ],
      ),
    );
  }
}



