import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhPaymentMethodTile.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/supply_categories.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_donation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VictimDonationScreen extends StatelessWidget {
  const VictimDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimDonationController());

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
            ],
          )),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _MoneyDonationTab();
              } else {
                return _SuppliesDonationTab();
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
    final controller = Get.find<VictimDonationController>();

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
    final controller = Get.find<VictimDonationController>();

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
          Text(
            "Danh mục vật phẩm",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems / 2),
          Obx(() => DropdownButtonFormField<SupplyCategory>(
                value: controller.selectedCategory.value,
                decoration: InputDecoration(
                  labelText: "Chọn danh mục",
                  prefixIcon: Icon(Iconsax.category),
                  border: OutlineInputBorder(),
                ),
                items: SupplyCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        SizedBox(width: 8),
                        Text(category.viName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedCategory.value = value;
                },
              )),
          if (controller.selectedCategory.value == SupplyCategory.other) ...[
            SizedBox(height: MinhSizes.spaceBtwItems),
            TextField(
              controller: controller.customCategoryController,
              decoration: InputDecoration(
                labelText: "Tên danh mục tùy chỉnh",
                prefixIcon: Icon(Iconsax.edit),
                border: OutlineInputBorder(),
              ),
            ),
          ],
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


