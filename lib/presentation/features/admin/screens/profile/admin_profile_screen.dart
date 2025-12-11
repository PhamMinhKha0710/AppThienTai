import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhUserProfileTitle.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/domain/usecases/logout_usecase.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

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
                      "Tài khoản",
                      style: Theme.of(context).textTheme.headlineMedium!.apply(
                        color: MinhColors.white,
                      ),
                    ),
                  ),
                  MinhUserProfileTitle(
                    onPressed: () {
                      Get.to(() => const ProfileScreen());
                    },
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwSections),
                ],
              ),
            ),

            const SizedBox(height: MinhSizes.spaceBtwItems),

            // Body
            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                children: [
                  // Thông tin cá nhân
                  MinhSectionHeading(
                    title: "Thông tin cá nhân",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.user,
                          title: "Chỉnh sửa hồ sơ",
                          subtitle: "Cập nhật thông tin cá nhân",
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () {
                            Get.to(() => const ProfileScreen());
                          },
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.lock,
                          title: "Đổi mật khẩu",
                          subtitle: "Thay đổi mật khẩu đăng nhập",
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

                  // Cài đặt tài khoản
                  MinhSectionHeading(
                    title: "Cài đặt tài khoản",
                    showActionButton: false,
                  ),
                  const SizedBox(height: MinhSizes.spaceBtwItems),
                  Card(
                    child: Column(
                      children: [
                        MinhSettingsMenuTitle(
                          icon: Iconsax.notification,
                          title: "Thông báo",
                          subtitle: "Quản lý thông báo",
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // TODO: Save notification preference
                            },
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.location,
                          title: "Vị trí",
                          subtitle: "Chia sẻ vị trí",
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              // TODO: Save location sharing preference
                            },
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        MinhSettingsMenuTitle(
                          icon: Iconsax.security_user,
                          title: "Chế độ riêng tư",
                          subtitle: "Bảo mật tài khoản",
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
                          title: "Trợ giúp",
                          subtitle: "Câu hỏi thường gặp",
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
                          icon: Iconsax.message,
                          title: "Liên hệ hỗ trợ",
                          subtitle: "Gửi phản hồi",
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

                  // Đăng xuất
                  Card(
                    color: Colors.red.shade50,
                    child: MinhSettingsMenuTitle(
                      icon: Iconsax.logout,
                      title: "Đăng xuất",
                      subtitle: "Đăng xuất khỏi tài khoản",
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Đăng xuất'),
                            content: const Text('Bạn có chắc muốn đăng xuất?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                  try {
                                    final logoutUseCase = Get.find<LogoutUseCase>();
                                    await logoutUseCase();
                                    Get.offAll(() => const LoginScreen());
                                  } catch (e) {
                                    Get.snackbar(
                                      'Lỗi',
                                      'Không thể đăng xuất: $e',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Đăng xuất'),
                              ),
                            ],
                          ),
                        );
                      },
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

