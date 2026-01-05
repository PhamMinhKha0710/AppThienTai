import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/area_coordinator_controller.dart';
import 'package:cuutrobaolu/domain/entities/area_coordinator_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AreaCoordinatorApplicationScreen extends StatelessWidget {
  const AreaCoordinatorApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AreaCoordinatorController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Đăng ký điều phối khu vực"),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final status = controller.coordinatorStatus.value;

        return SingleChildScrollView(
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status != null) ...[
                Card(
                  color: _getStatusColor(status.status).withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(MinhSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(status.status),
                              color: _getStatusColor(status.status),
                            ),
                            SizedBox(width: MinhSizes.spaceBtwItems / 2),
                            Text(
                              "Trạng thái đăng ký",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems / 2),
                        Text(
                          status.status.viName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.apply(
                                color: _getStatusColor(status.status),
                              ),
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems / 2),
                        Text("Khu vực: ${status.province}${status.district != null ? ' - ${status.district}' : ''}"),
                        Text("Ngày đăng ký: ${_formatDate(status.appliedAt)}"),
                        if (status.approvedAt != null)
                          Text("Ngày duyệt: ${_formatDate(status.approvedAt!)}"),
                        if (status.rejectionReason != null) ...[
                          SizedBox(height: MinhSizes.spaceBtwItems / 2),
                          Text(
                            "Lý do từ chối: ${status.rejectionReason}",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MinhSizes.spaceBtwSections),
              ],
              Text(
                status == null || status.isRejected
                    ? "Đăng ký làm điều phối khu vực"
                    : "Thông tin đăng ký",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: controller.provinceController,
                enabled: status == null || status.isRejected,
                decoration: InputDecoration(
                  labelText: "Tỉnh/Thành phố *",
                  prefixIcon: Icon(Iconsax.location),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: controller.districtController,
                enabled: status == null || status.isRejected,
                decoration: InputDecoration(
                  labelText: "Huyện/Quận (tùy chọn)",
                  prefixIcon: Icon(Iconsax.map),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: MinhSizes.spaceBtwItems),
              TextField(
                controller: controller.reasonController,
                enabled: status == null || status.isRejected,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Lý do đăng ký (tùy chọn)",
                  prefixIcon: Icon(Iconsax.document_text),
                  border: OutlineInputBorder(),
                ),
              ),
              if (status == null || status.isRejected) ...[
                SizedBox(height: MinhSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.applyAsCoordinator(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: MinhSizes.buttonHeight,
                      ),
                    ),
                    child: Text("Gửi đơn đăng ký"),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(AreaCoordinatorStatus status) {
    switch (status) {
      case AreaCoordinatorStatus.pending:
        return Colors.orange;
      case AreaCoordinatorStatus.approved:
        return Colors.green;
      case AreaCoordinatorStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AreaCoordinatorStatus status) {
    switch (status) {
      case AreaCoordinatorStatus.pending:
        return Iconsax.clock;
      case AreaCoordinatorStatus.approved:
        return Iconsax.tick_circle;
      case AreaCoordinatorStatus.rejected:
        return Iconsax.close_circle;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}



















