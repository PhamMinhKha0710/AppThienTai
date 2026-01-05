import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/tabs/MinhTabButton.dart';
import 'package:cuutrobaolu/core/widgets/cards/MinhPaymentMethodTile.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/supply_categories.dart';
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
                      label: "Góp sức",
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
                return _TimeDonationTab(); // Renaming this class content next
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

    // Listen for QR code show request
    ever(controller.showQrCode, (show) {
      if (show) {
        _showQrDialog(context, controller);
      }
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(MinhSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Featured Campaign Card
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.blue.shade100,
                  child: Center(
                    child: Icon(Icons.volunteer_activism, size: 50, color: Colors.blue),
                  ),
                  // In real app: Image.network(campaignUrl, fit: BoxFit.cover)
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chung tay hỗ trợ đồng bào bão Yagi",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: 0.7, color: MinhColors.primary),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Đã quyên góp: 7 tỷ VNĐ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("Mục tiêu: 10 tỷ VNĐ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwSections),

          // 2. Donation Amount
          Text(
            "Nhập số tiền quyên góp",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MinhColors.primary),
            decoration: InputDecoration(
              labelText: "Số tiền (VNĐ)",
              prefixIcon: Icon(Iconsax.dollar_circle),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixText: "VNĐ",
            ),
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          
          // Quick Amounts Grid
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.quickAmounts.map((amount) {
              final isSelected = controller.selectedQuickAmount.value == amount;
              return ChoiceChip(
                label: Text("${amount ~/ 1000}k"),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.selectQuickAmount(amount);
                },
                selectedColor: MinhColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          )),
          
          SizedBox(height: MinhSizes.spaceBtwSections),

          // 3. Payment Method
          Text(
            "Phương thức thanh toán",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          Obx(() => Column(
                children: [
                  MinhPaymentMethodTile(
                    icon: Iconsax.wallet,
                    title: "Ví điện tử (Momo/ZaloPay)",
                    isSelected: controller.paymentMethod.value == 'wallet',
                    onTap: () => controller.paymentMethod.value = 'wallet',
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  MinhPaymentMethodTile(
                    icon: Iconsax.bank,
                    title: "Chuyển khoản ngân hàng (VietQR)",
                    isSelected: controller.paymentMethod.value == 'bank',
                    onTap: () => controller.paymentMethod.value = 'bank',
                  ),
                ],
              )),
          
          SizedBox(height: MinhSizes.spaceBtwSections),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (controller.paymentMethod.value == 'wallet' || 
                    controller.paymentMethod.value == 'bank') {
                  controller.processQrPayment(context);
                } else {
                  controller.submitMoneyDonation();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MinhColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Tiếp tục", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, VolunteerDonationController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Quét mã thanh toán"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: 200,
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, size: 100),
                  SizedBox(height: 8),
                  Text("Mặt trận Tổ quốc Việt Nam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("VietinBank: 1111 2222 3333", style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Vui lòng quét mã trên để quyên góp ${controller.amountController.text} VNĐ",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                "Lưu ý: Toàn bộ số tiền sẽ được chuyển trực tiếp vào tài khoản của Mặt trận Tổ quốc Việt Nam.",
                style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.showQrCode.value = false;
              Navigator.pop(context);
            },
            child: Text("Hủy"),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessingPayment.value 
              ? null 
              : () async {
                  await controller.verifyPayment();
                  Navigator.pop(context);
                },
            child: controller.isProcessingPayment.value
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Đã chuyển tiền"),
          )),
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
          
          Text(
            "Chọn danh mục",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          
          // Category Grid
          Obx(() => GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: SupplyCategory.values.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              return _SupplyCategoryCard(
                category: category,
                isSelected: isSelected,
                onTap: () => controller.selectedCategory.value = category,
              );
            }).toList(),
          )),
          
          SizedBox(height: MinhSizes.spaceBtwSections),
          
          // Input Fields
          Obx(() {
            if (controller.selectedCategory.value == null) {
               return Center(
                 child: Text(
                   "Vui lòng chọn danh mục để tiếp tục",
                   style: TextStyle(color: Colors.grey),
                 ),
               );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thông tin chi tiết",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: MinhSizes.spaceBtwItems),
                
                if (controller.selectedCategory.value == SupplyCategory.other) ...[
                  TextField(
                    controller: controller.customCategoryController,
                    decoration: InputDecoration(
                      labelText: "Tên danh mục tùy chỉnh",
                      prefixIcon: Icon(Iconsax.edit),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                ],

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controller.itemNameController,
                        decoration: InputDecoration(
                          labelText: "Tên vật phẩm",
                          prefixIcon: Icon(Iconsax.box),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: controller.quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Số lượng",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MinhSizes.spaceBtwItems),
                TextField(
                  controller: controller.itemDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Mô tả / Ghi chú (Tình trạng, HSD...)",
                    prefixIcon: Icon(Iconsax.document_text),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: MinhSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.submitSuppliesDonation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                     child: Text("Xác nhận quyên góp", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SupplyCategoryCard extends StatelessWidget {
  final SupplyCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SupplyCategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: category.color.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon, 
              color: isSelected ? category.color : Colors.grey, 
              size: 32
            ),
            SizedBox(height: 8),
            Text(
              category.viName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? category.color : Colors.grey.shade800,
              ),
            ),
          ],
        ),
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
            "Đăng ký tham gia tình nguyện",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          
          // 1. Skill Selection
          Text(
            "Bạn có thể hỗ trợ lĩnh vực nào?",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems / 2),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableSkills.map((skill) {
              final isSelected = controller.selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) => controller.toggleSkill(skill),
                selectedColor: Colors.green.withOpacity(0.2),
                checkmarkColor: Colors.green,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green.shade800 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          )),
          
          SizedBox(height: MinhSizes.spaceBtwSections),

          // 2. Date Selection
          Text(
            "Thời gian bạn có thể tham gia",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Chọn ngày bắt đầu",
              prefixIcon: Icon(Iconsax.calendar),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: Icon(Iconsax.calendar_1),
            ),
            onTap: () => controller.selectDate(context),
          ),
          
          SizedBox(height: MinhSizes.spaceBtwItems),
          TextField(
            controller: controller.timeDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Ghi chú thêm (Kinh nghiệm, Sức khỏe...)",
              prefixIcon: Icon(Iconsax.edit),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              alignLabelWithHint: true,
            ),
          ),
          
          SizedBox(height: MinhSizes.spaceBtwSections),
          
          // 3. Stats Card (Updated Logic needed if we remove hours)
          // For now, we can hide exact hours or show "Events Joined"
          Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(MinhSizes.defaultSpace),
              child: Row(
                children: [
                   Icon(Icons.volunteer_activism, color: Colors.green, size: 40),
                   SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("Cộng đồng cần bạn!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         SizedBox(height: 4),
                         Text("Mỗi đóng góp công sức đều giúp đỡ đồng bào vượt qua khó khăn.", style: TextStyle(fontSize: 12)),
                       ],
                     ),
                   )
                ],
              ),
            ),
          ),
          
          SizedBox(height: MinhSizes.spaceBtwSections),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.submitTimeDonation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Đăng ký tham gia", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}








