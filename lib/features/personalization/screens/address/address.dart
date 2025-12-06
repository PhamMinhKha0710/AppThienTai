import 'package:cuutrobaolu/common/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/features/personalization/screens/address/add_new_address.dart';
import 'package:cuutrobaolu/features/personalization/screens/address/widgets/MinhSingleAddress.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nút hành động nổi để thêm địa chỉ mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng đến màn hình thêm địa chỉ mới
          Get.to(() => const AddNewAddressScreen());
        },
        backgroundColor: MinhColors.primary,
        child: const Icon(
          Iconsax.add,
          color: MinhColors.white,
        ),
      ),
      appBar: MinhAppbar(
        title: Text(
          "Địa chỉ của tôi", // Cập nhật tiêu đề cho phù hợp
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MinhSizes.defaultSpace),
          child: Column(
            children: [
              // Sử dụng widget MinhSingleAddress với dữ liệu mẫu
              MinhSingleAddress(
                selectAddress: true,
                name: "Đinh Công Minh",
                phone: "(+84) 776 117 577",
                address: "1496/1, KP3, P. Trảng Dài, Biên Hòa, Đồng Nai",
              ),
              MinhSingleAddress(
                selectAddress: false,
                name: "Nguyễn Văn An",
                phone: "(+84) 123 456 789",
                address: "123 Đường Lê Lợi, Phường Bến Thành, Quận 1, TP.HCM",
              ),
              MinhSingleAddress(
                selectAddress: false,
                name: "Trần Thị Bích",
                phone: "(+84) 987 654 321",
                address: "456 Đường Nguyễn Huệ, Phường Hàng Bài, Quận Hoàn Kiếm, Hà Nội",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
