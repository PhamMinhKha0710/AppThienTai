import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhPaymentMethodTile.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_donation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VolunteerDonationScreen extends StatelessWidget {
  const VolunteerDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerDonationController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Quyên góp"),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Tabs
          Obx(() => Row(
                children: [
                  Expanded(
                    child: MinhTabButton(
                      label: "Tiền mặt",
                      isSelected: controller.selectedTab.value == 0,
                      onTap: () => controller.selectedTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: MinhTabButton(
                      label: "Nhu yếu phẩm",
                      isSelected: controller.selectedTab.value == 1,
                      onTap: () => controller.selectedTab.value = 1,
                    ),
                  ),
                  Expanded(
                    child: MinhTabButton(
                      label: "Thời gian",
                      isSelected: controller.selectedTab.value == 2,
                      onTap: () => controller.selectedTab.value = 2,
                    ),
                  ),
                ],
              )),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _MoneyDonationTab();
              } else if (controller.selectedTab.value == 1) {
                return _SuppliesDonationTab();
              } else {
                return _TimeDonationTab();
              }
            }),
          ),
        ],
      ),
    );
  }
}

class _MoneyDonationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerDonationController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(MinhSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quyên góp tiền mặt",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Số tiền (VNĐ)",
              prefixIcon: Icon(Iconsax.dollar_circle),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          Text(
            "Phương thức thanh toán",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          Obx(() => Column(
                children: [
                  MinhPaymentMethodTile(
                    icon: Iconsax.wallet,
                    title: "Ví điện tử",
                    isSelected: controller.paymentMethod.value == 'wallet',
                    onTap: () => controller.paymentMethod.value = 'wallet',
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  MinhPaymentMethodTile(
                    icon: Iconsax.bank,
                    title: "Chuyển khoản ngân hàng",
                    isSelected: controller.paymentMethod.value == 'bank',
                    onTap: () => controller.paymentMethod.value = 'bank',
                  ),
                ],
              )),
          SizedBox(height: MinhSizes.spaceBtwSections),
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tổng quyên góp toàn hệ thống",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems / 2),
                  Obx(() => Text(
                        "${controller.totalDonation.value.toStringAsFixed(0)} VNĐ",
                        style: Theme.of(context).textTheme.headlineMedium?.apply(
                              color: MinhColors.primary,
                            ),
                      )),
                ],
              ),
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.submitMoneyDonation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: MinhColors.primary,
                padding: EdgeInsets.symmetric(vertical: MinhSizes.buttonHeight),
              ),
              child: Text("Xác nhận quyên góp"),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuppliesDonationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerDonationController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(MinhSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quyên góp nhu yếu phẩm",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.itemNameController,
            decoration: InputDecoration(
              labelText: "Tên vật phẩm",
              prefixIcon: Icon(Iconsax.box),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Số lượng",
              prefixIcon: Icon(Iconsax.hashtag),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.itemDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Mô tả",
              prefixIcon: Icon(Iconsax.document_text),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.submitSuppliesDonation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: MinhColors.primary,
                padding: EdgeInsets.symmetric(vertical: MinhSizes.buttonHeight),
              ),
              child: Text("Xác nhận quyên góp"),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeDonationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerDonationController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(MinhSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quyên góp thời gian",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems / 2),
          Text(
            "Đăng ký thời gian bạn có thể tình nguyện",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwSections),
          TextField(
            controller: controller.hoursController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Số giờ",
              prefixIcon: Icon(Iconsax.clock),
              border: OutlineInputBorder(),
              helperText: "Ví dụ: 4, 8, 12 giờ",
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Ngày",
              prefixIcon: Icon(Iconsax.calendar),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Iconsax.calendar_1),
            ),
            onTap: () => controller.selectDate(context),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.timeDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Mô tả hoạt động (tùy chọn)",
              prefixIcon: Icon(Iconsax.document_text),
              border: OutlineInputBorder(),
              helperText: "Mô tả loại công việc bạn muốn làm",
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwSections),
          Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.clock, color: Colors.green),
                      SizedBox(width: MinhSizes.spaceBtwItems / 2),
                      Text(
                        "Tổng thời gian đã quyên góp",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems / 2),
                  Obx(() => Text(
                        "${controller.totalTimeDonated.value} giờ",
                        style: Theme.of(context).textTheme.headlineMedium?.apply(
                              color: Colors.green,
                            ),
                      )),
                  SizedBox(height: MinhSizes.spaceBtwItems / 2),
                  Text(
                    "Cảm ơn bạn đã đóng góp thời gian cho cộng đồng!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.submitTimeDonation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: MinhSizes.buttonHeight),
              ),
              child: Text("Đăng ký quyên góp thời gian"),
            ),
          ),
        ],
      ),
    );
  }
}





