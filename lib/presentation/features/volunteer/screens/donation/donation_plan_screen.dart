import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/supply_categories.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/donation_plan_controller.dart';
import 'package:cuutrobaolu/domain/entities/donation_plan_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DonationPlanScreen extends StatelessWidget {
  const DonationPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DonationPlanController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Kế hoạch quyên góp"),
        showBackArrow: true,
        action: [
          IconButton(
            icon: Icon(Iconsax.add),
            onPressed: () => _showCreatePlanDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.document, size: 64, color: Colors.grey),
                SizedBox(height: MinhSizes.spaceBtwItems),
                Text(
                  "Chưa có kế hoạch quyên góp",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: MinhSizes.spaceBtwItems / 2),
                Text(
                  "Nhấn nút + để tạo kế hoạch mới",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          itemCount: controller.plans.length,
          itemBuilder: (context, index) {
            final plan = controller.plans[index];
            return Card(
              margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
              child: ListTile(
                title: Text(plan.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${plan.province}${plan.district != null ? ' - ${plan.district}' : ''}"),
                    Text("${plan.requiredItems.length} vật phẩm cần quyên góp"),
                    Text(
                      plan.status.viName,
                      style: TextStyle(
                        color: plan.status == DonationPlanStatus.active
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.edit),
                      onPressed: () => _showEditPlanDialog(context, controller, plan),
                    ),
                    IconButton(
                      icon: Icon(Iconsax.trash),
                      onPressed: () => controller.deletePlan(plan.id),
                    ),
                  ],
                ),
                onTap: () => _showPlanDetails(context, plan),
              ),
            );
          },
        );
      }),
    );
  }

  void _showCreatePlanDialog(
      BuildContext context, DonationPlanController controller) {
    controller.clearForm();
    _showPlanFormDialog(context, controller, null);
  }

  void _showEditPlanDialog(BuildContext context,
      DonationPlanController controller, DonationPlanEntity plan) {
    controller.loadPlanForEdit(plan);
    _showPlanFormDialog(context, controller, plan);
  }

  void _showPlanFormDialog(BuildContext context,
      DonationPlanController controller, DonationPlanEntity? plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan == null ? "Tạo kế hoạch quyên góp" : "Chỉnh sửa kế hoạch"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(labelText: "Tiêu đề"),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: controller.provinceController,
                decoration: InputDecoration(labelText: "Tỉnh/Thành phố"),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: controller.districtController,
                decoration: InputDecoration(labelText: "Huyện/Quận (tùy chọn)"),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Mô tả"),
              ),
              SizedBox(height: MinhSizes.spaceBtwSections),
              Text("Vật phẩm cần quyên góp:"),
              Obx(() => Column(
                    children: controller.requiredItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return ListTile(
                        title: Text(item.categoryName),
                        subtitle: Text("Số lượng: ${item.quantity}"),
                        trailing: IconButton(
                          icon: Icon(Iconsax.trash),
                          onPressed: () => controller.removeRequiredItem(index),
                        ),
                      );
                    }).toList(),
                  )),
              ElevatedButton(
                onPressed: () => _showAddItemDialog(context, controller),
                child: Text("Thêm vật phẩm"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.createPlan();
              Navigator.pop(context);
            },
            child: Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(
      BuildContext context, DonationPlanController controller) {
    final categoryController = Rxn<SupplyCategory>();
    final customCategoryController = TextEditingController();
    final quantityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm vật phẩm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<SupplyCategory>(
              value: categoryController.value,
              decoration: InputDecoration(labelText: "Danh mục"),
              items: SupplyCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.viName),
                );
              }).toList(),
              onChanged: (value) => categoryController.value = value,
            ),
            if (categoryController.value == SupplyCategory.other) ...[
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: customCategoryController,
                decoration: InputDecoration(labelText: "Tên danh mục tùy chỉnh"),
              ),
            ],
            SizedBox(height: MinhSizes.spaceBtwItems),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Số lượng"),
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Mô tả (tùy chọn)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.value != null &&
                  quantityController.text.isNotEmpty) {
                controller.addRequiredItem(
                  category: categoryController.value,
                  customCategory: categoryController.value == SupplyCategory.other
                      ? customCategoryController.text
                      : null,
                  quantity: int.parse(quantityController.text),
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text("Thêm"),
          ),
        ],
      ),
    );
  }

  void _showPlanDetails(BuildContext context, DonationPlanEntity plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Khu vực: ${plan.province}${plan.district != null ? ' - ${plan.district}' : ''}"),
              if (plan.description != null) ...[
                SizedBox(height: MinhSizes.spaceBtwItems),
                Text("Mô tả: ${plan.description}"),
              ],
              SizedBox(height: MinhSizes.spaceBtwItems),
              Text("Vật phẩm cần quyên góp:"),
              ...plan.requiredItems.map((item) {
                return ListTile(
                  title: Text(item.categoryName),
                  subtitle: Text("Số lượng: ${item.quantity}"),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng"),
          ),
        ],
      ),
    );
  }
}

