import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhUserProfileTitle.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/domain/usecases/logout_usecase.dart';
import 'package:cuutrobaolu/domain/repositories/authentication_repository.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_profile_controller.dart';
import 'package:cuutrobaolu/presentation/features/victim/NavigationVictimController.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VictimProfileScreen extends StatelessWidget {
  const VictimProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final victimProfileController = Get.put(VictimProfileController(), permanent: false);
    
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
                      "Cá nhân",
                      style: Theme.of(context).textTheme.headlineMedium!.apply(
                        color: MinhColors.white,
                      ),
                    ),
                  ),
                  MinhUserProfileTitle(
                    onPressed: () {
                      Get.to(() => ProfileScreen());
                    },
                  ),
                  SizedBox(height: MinhSizes.spaceBtwSections),
                ],
              ),
            ),

            SizedBox(height: MinhSizes.spaceBtwItems),

            // Body
            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                children: [
                  // Quick Access Section
                  MinhSectionHeading(
                    title: "Truy cập nhanh",
                    showActionButton: false,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  
                  // Quick Access Cards
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Iconsax.notification_bing,
                          title: "Thông báo\ncứu trợ",
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to alerts screen (index 2 in navigation)
                            NavigationVictimController.selectedIndex.value = 2;
                          },
                        ),
                      ),
                      SizedBox(width: MinhSizes.spaceBtwItems),
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Iconsax.home_2,
                          title: "Nơi\ntrú ẩn",
                          color: Colors.teal,
                          onTap: () {
                            // Navigate to map screen with shelters (index 1)
                            NavigationVictimController.selectedIndex.value = 1;
                            Get.snackbar(
                              "Nơi trú ẩn",
                              "Xem các điểm trú ẩn gần bạn trên bản đồ",
                              icon: Icon(Iconsax.info_circle, color: Colors.white),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.teal,
                              colorText: Colors.white,
                              duration: Duration(seconds: 2),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: MinhSizes.spaceBtwItems),
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Iconsax.document_text,
                          title: "Tin tức\nthiên tai",
                          color: Colors.orange,
                          onTap: () {
                            // Navigate to news screen (index 3)
                            NavigationVictimController.selectedIndex.value = 3;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // My Requests Section
                  MinhSectionHeading(
                    title: "Yêu cầu của tôi",
                    showActionButton: false,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  
                  Obx(() {
                    final controller = victimProfileController;
                    
                    if (controller.isLoading.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(MinhSizes.defaultSpace),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.myRequests.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(MinhSizes.defaultSpace),
                        child: Text(
                          "Chưa có yêu cầu nào",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.myRequests.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: MinhSizes.spaceBtwItems / 2),
                      itemBuilder: (context, index) {
                        final request = controller.myRequests[index];
                        final statusColor = controller.getStatusColor(request['status']);
                        final severityColor = controller.getSeverityColor(request['severity']);

                        return Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(MinhSizes.md),
                            leading: Container(
                              padding: EdgeInsets.all(MinhSizes.sm),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
                              ),
                              child: Icon(
                                Iconsax.document_text,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              request['title'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  request['description'] ?? '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MinhSizes.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        request['statusVi'] ?? '',
                                        style: Theme.of(context).textTheme.bodySmall?.apply(
                                              color: statusColor,
                                              fontSizeFactor: 0.9,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: MinhSizes.spaceBtwItems / 2),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MinhSizes.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: severityColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        request['severityVi'] ?? '',
                                        style: Theme.of(context).textTheme.bodySmall?.apply(
                                              color: severityColor,
                                              fontSizeFactor: 0.9,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${request['timeStr']} • ${request['address'] ?? ''}',
                                  style: Theme.of(context).textTheme.bodySmall?.apply(
                                        color: MinhColors.darkerGrey,
                                      ),
                                ),
                              ],
                            ),
                            trailing: Icon(Iconsax.arrow_right_3),
                          ),
                        );
                      },
                    );
                  }),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Account Actions
                  MinhSectionHeading(
                    title: "Tài khoản",
                    showActionButton: false,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),

                  MinhSettingsMenuTitle(
                    icon: Iconsax.notification,
                    title: "Cài đặt thông báo",
                    subtitle: "Quản lý thông báo ứng dụng",
                    onTap: () {
                      Get.snackbar(
                        "Đang phát triển",
                        "Tính năng cài đặt thông báo sẽ sớm có",
                        icon: Icon(Iconsax.info_circle, color: Colors.white),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                  ),
                  
                  MinhSettingsMenuTitle(
                    icon: Iconsax.location,
                    title: "Vị trí",
                    subtitle: "Cho phép chia sẻ vị trí",
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                    onTap: () {},
                  ),

                  SizedBox(height: MinhSizes.spaceBtwSections),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          LogoutUseCase logoutUseCase;
                          try {
                            logoutUseCase = Get.find<LogoutUseCase>();
                          } catch (e) {
                            final authRepo = Get.find<AuthenticationRepository>();
                            logoutUseCase = LogoutUseCase(authRepo);
                            Get.put(logoutUseCase);
                          }
                          
                          await logoutUseCase();
                          Get.offAll(() => LoginScreen());
                        } on Failure catch (failure) {
                          Get.snackbar("Lỗi", failure.message);
                        } catch (e) {
                          Get.snackbar("Lỗi", "Không thể đăng xuất: ${e.toString()}");
                        }
                      },
                      child: Text("Đăng xuất"),
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwSections * 2.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: MinhSizes.md,
          horizontal: MinhSizes.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(MinhSizes.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(height: MinhSizes.spaceBtwItems / 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                color: color,
                fontWeightDelta: 2,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}








