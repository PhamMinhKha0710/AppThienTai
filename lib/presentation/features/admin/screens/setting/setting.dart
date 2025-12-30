import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/notification_settings_screen.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/support_hub_screen.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/widgets/ChangePassword.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingAdminScreen extends StatelessWidget {
  const SettingAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            MinhPrimaryHeaderContainer(
              child: Column(
                children: [
                  MinhAppbar(
                    title: Text(
                      "Cài đặt hệ thống",
                      style: Theme.of(context).textTheme.headlineMedium!.apply(
                        color: MinhColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwSections),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                children: [
                  // Thông báo & Cảnh báo
                  MinhSectionHeading(
                    title: "Thông báo & Cảnh báo",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.notification,
                          title: "Cài đặt thông báo",
                          subtitle: "Quản lý thông báo push và email",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.to(() => const NotificationSettingsScreen());
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.danger,
                          title: "Cảnh báo khẩn cấp",
                          subtitle: "Cấu hình hệ thống cảnh báo",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: MinhSizes.spaceBtwSections),

                  // Bảo mật & Quyền
                  MinhSectionHeading(
                    title: "Bảo mật & Quyền",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.shield,
                          title: "Quản lý quyền truy cập",
                          subtitle: "Phân quyền người dùng và admin",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.lock,
                          title: "Đổi mật khẩu",
                          subtitle: "Thay đổi mật khẩu tài khoản",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.to(() => const ChangePassword());
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.activity,
                          title: "Nhật ký hoạt động",
                          subtitle: "Xem lịch sử thao tác hệ thống",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: MinhSizes.spaceBtwSections),

                  // Dữ liệu & Backup
                  MinhSectionHeading(
                    title: "Dữ liệu & Backup",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.document_download,
                          title: "Sao lưu dữ liệu",
                          subtitle: "Tạo backup hệ thống",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.document_upload,
                          title: "Khôi phục dữ liệu",
                          subtitle: "Restore từ backup",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.trash,
                          title: "Xóa dữ liệu cũ",
                          subtitle: "Dọn dẹp dữ liệu không cần thiết",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Xóa dữ liệu cũ'),
                                content: const Text('Bạn có chắc muốn xóa dữ liệu cũ? Hành động này không thể hoàn tác.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.snackbar(
                                        'Thông báo',
                                        'Tính năng đang phát triển',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: MinhSizes.spaceBtwSections),

                  // Hệ thống
                  MinhSectionHeading(
                    title: "Hệ thống",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.setting_2,
                          title: "Cấu hình chung",
                          subtitle: "Cài đặt hệ thống cơ bản",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.global,
                          title: "Ngôn ngữ & Vùng",
                          subtitle: "Thiết lập ngôn ngữ hiển thị",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.snackbar(
                              'Thông báo',
                              'Tính năng đang phát triển',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.info_circle,
                          title: "Về ứng dụng",
                          subtitle: "Phiên bản và thông tin",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Về ứng dụng'),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ứng dụng Quản lý Cứu trợ Thiên tai'),
                                    SizedBox(height: 8),
                                    Text('Phiên bản: 1.0.0'),
                                    SizedBox(height: 8),
                                    Text('© 2025 All rights reserved'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: MinhSizes.spaceBtwSections),

                  // Hỗ trợ
                  MinhSectionHeading(
                    title: "Hỗ trợ",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.message_question,
                          title: "Trung tâm hỗ trợ",
                          subtitle: "FAQ, liên hệ, hướng dẫn sử dụng",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.to(() => const SupportHubScreen());
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: MinhSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
