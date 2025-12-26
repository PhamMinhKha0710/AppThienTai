import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';

import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/home/widgets/MinhHomeAppbar.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/home/widgets/MinhHomeCategory.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/home/widgets/MinhPromoSlider.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/widgets/custom_shapes/containers/MinhSearchContainer.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Get.put để đảm bảo UserController được khởi tạo nếu chưa có
    final userController = Get.put(UserController());


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Primary
            MinhPrimaryHeaderContainer(
              child: Column(
                children: [
                  // Appbar
                  MinhHomeAppbar(),
                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Search - Hiển thị khác nhau theo user type
                  Obx(() {
                    final userType = userController.user.value.userType;
                    String searchText = "Tìm kiếm...";
                    if (userType.enName.toLowerCase() == 'volunteer') {
                      searchText = "Tìm yêu cầu cần hỗ trợ";
                    } else if (userType.enName.toLowerCase() == 'admin') {
                      searchText = "Tìm kiếm quản trị";
                    } else {
                      searchText = "Tìm kiếm hỗ trợ";
                    }
                    return MinhSearchContainer(
                      text: searchText,
                      icon: Iconsax.search_normal,
                    );
                  }),
                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Category - Hiển thị khác nhau theo user type
                  Obx(() {
                    final userType = userController.user.value.userType;
                    return Padding(
                      padding: EdgeInsets.only(left: MinhSizes.defaultSpace),
                      child: Column(
                        children: [
                          // heading - Khác nhau theo user type
                          MinhSectionHeading(
                            title: userType.enName.toLowerCase() == 'volunteer'
                                ? "Danh mục hỗ trợ"
                                : userType.enName.toLowerCase() == 'admin'
                                    ? "Quản lý hệ thống"
                                    : "Danh mục cần hỗ trợ",
                            buttonTitle: "buttonTitle",
                            textColor: MinhColors.white,
                            showActionButton: false,
                          ),
                          SizedBox(height: MinhSizes.spaceBtwItems),

                          // category
                          MinhHomeCategory(),
                          SizedBox(height: MinhSizes.spaceBtwSections),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                ],
              ),
            ),

            // Couser
            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                children: [
                  MinhPromoSlider(),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Section heading - Khác nhau theo user type
                  Obx(() {
                    final userType = userController.user.value.userType;
                    String title = "Sản phẩm phổ biến";
                    if (userType.enName.toLowerCase() == 'volunteer') {
                      title = "Yêu cầu cần hỗ trợ";
                    } else if (userType.enName.toLowerCase() == 'admin') {
                      title = "Quản lý yêu cầu";
                    } else {
                      title = "Yêu cầu của tôi";
                    }
                    return MinhSectionHeading(
                      title: title,
                      showActionButton: true,
                      onPressed: () {},
                    );
                  }),
                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Popular Product

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
