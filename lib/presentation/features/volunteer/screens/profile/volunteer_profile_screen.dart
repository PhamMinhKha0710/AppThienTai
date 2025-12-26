import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhPrimaryHeaderContainer.dart';
import 'package:cuutrobaolu/core/widgets/images/MinhCircularImage.dart';
import 'package:cuutrobaolu/core/widgets/list_titles/MinhSettingsMenuTitle.dart';
import 'package:cuutrobaolu/core/widgets/texts/MinhSectionHeading.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_profile_controller.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/donation/volunteer_donation_screen.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/domain/usecases/logout_usecase.dart';
import 'package:cuutrobaolu/domain/repositories/authentication_repository.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerProfileController());
    final userController = Get.put(UserController());

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
                      "Hồ sơ Tình nguyện viên",
                      style: Theme.of(context).textTheme.headlineMedium!.apply(
                            color: MinhColors.white,
                          ),
                    ),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  // Avatar & Name
                  Obx(() {
                    final user = userController.user.value;
                    final networkImage = user.profilePicture;
                    final image = networkImage.isEmpty ? MinhImages.user : networkImage;
                    return Column(
                      children: [
                        GestureDetector(
                          child: MinhCircularImage(
                            image: image,
                            width: 80,
                            height: 80,
                            isNetworkImage: networkImage.isNotEmpty,
                          ),
                          onTap: () {Get.to(() => ProfileScreen());},
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems / 2),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.headlineSmall!.apply(
                                color: MinhColors.white,
                              ),
                        ),
                        SizedBox(height: MinhSizes.spaceBtwItems / 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: MinhColors.white.withOpacity(0.8),
                              ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  // Stats
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Iconsax.task_square,
                            label: 'Nhiệm vụ',
                            value: '${controller.completedTasksCount.value}',
                            color: MinhColors.white,
                          ),
                          _StatItem(
                            icon: Iconsax.clock,
                            label: 'Giờ làm',
                            value: '${controller.totalHours.value}h',
                            color: MinhColors.white,
                          ),
                          _StatItem(
                            icon: Iconsax.heart,
                            label: 'Đóng góp',
                            value: '${controller.contributionsCount.value}',
                            color: MinhColors.white,
                          ),
                        ],
                      )),
                  SizedBox(height: MinhSizes.spaceBtwSections),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(MinhSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills Section
                  MinhSectionHeading(
                    title: "Kỹ năng",
                    showActionButton: true,
                    buttonTitle: "Thêm",
                    onPressed: () => controller.addSkill(),
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  Obx(() => Wrap(
                        spacing: MinhSizes.spaceBtwItems / 2,
                        runSpacing: MinhSizes.spaceBtwItems / 2,
                        children: [
                          ...controller.availableSkills.map((skill) {
                            final isSelected = controller.skills.contains(skill);
                            return FilterChip(
                              label: Text(skill),
                              selected: isSelected,
                              onSelected: (_) => controller.toggleSkill(skill),
                              selectedColor: MinhColors.primary.withOpacity(0.2),
                              checkmarkColor: MinhColors.primary,
                            );
                          }),
                        ],
                      )),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Settings Section
                  MinhSectionHeading(
                    title: "Cài đặt",
                    showActionButton: false,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),
                  Obx(() => MinhSettingsMenuTitle(
                        icon: Iconsax.toggle_on,
                        title: "Sẵn sàng nhận nhiệm vụ",
                        subtitle: controller.isAvailable.value
                            ? "Đang sẵn sàng"
                            : "Không sẵn sàng",
                        trailing: Switch(
                          value: controller.isAvailable.value,
                          onChanged: controller.toggleAvailability,
                        ),
                        onTap: () {},
                      )),
                  Obx(() => MinhSettingsMenuTitle(
                        icon: Iconsax.notification,
                        title: "Thông báo",
                        subtitle: controller.notificationsEnabled.value
                            ? "Đã bật"
                            : "Đã tắt",
                        trailing: Switch(
                          value: controller.notificationsEnabled.value,
                          onChanged: controller.toggleNotifications,
                        ),
                        onTap: () {},
                      )),
                  Obx(() => MinhSettingsMenuTitle(
                        icon: Iconsax.location,
                        title: "Chia sẻ vị trí",
                        subtitle: controller.locationSharingEnabled.value
                            ? "Đang chia sẻ"
                            : "Không chia sẻ",
                        trailing: Switch(
                          value: controller.locationSharingEnabled.value,
                          onChanged: controller.toggleLocationSharing,
                        ),
                        onTap: () {},
                      )),
                  MinhSettingsMenuTitle(
                    icon: Iconsax.heart,
                    title: "Quyên góp",
                    subtitle: "Quyên góp tiền, vật phẩm hoặc thời gian",
                    onTap: () {
                      Get.to(() => VolunteerDonationScreen());
                    },
                  ),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          // Get LogoutUseCase
                          LogoutUseCase logoutUseCase;
                          try {
                            logoutUseCase = Get.find<LogoutUseCase>();
                          } catch (e) {
                            // If not found, create new from dependencies
                            try {
                              final authRepo = Get.find<AuthenticationRepository>();
                              logoutUseCase = LogoutUseCase(authRepo);
                              Get.put(logoutUseCase);
                            } catch (e2) {
                              Get.snackbar("Lỗi", "Không thể khởi tạo LogoutUseCase: ${e2.toString()}");
                              return;
                            }
                          }
                          
                          // Perform logout
                          await logoutUseCase();
                          
                          // Navigate to login (logout already cleared session)
                          Get.offAll(() => LoginScreen());
                        } catch (e) {
                          Get.snackbar("Lỗi", "Không thể đăng xuất: ${e.toString()}");
                        }
                      },
                      icon: Icon(Iconsax.logout, color: Colors.red),
                      label: Text(
                        "Đăng xuất",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: MinhSizes.md),
                      ),
                    ),
                  ),

                  SizedBox(height: MinhSizes.spaceBtwSections),

                  // History Section
                  MinhSectionHeading(
                    title: "Lịch sử",
                    showActionButton: false,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems),

                  // Completed Tasks
                  Text(
                    "Nhiệm vụ đã hoàn thành",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems / 2),
                  Obx(() => controller.completedTasks.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(MinhSizes.defaultSpace),
                          child: Text(
                            "Chưa có nhiệm vụ nào",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.completedTasks.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: MinhSizes.spaceBtwItems / 2),
                          itemBuilder: (context, index) {
                            final task = controller.completedTasks[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(Iconsax.task_square,
                                    color: MinhColors.primary),
                                title: Text(task['title'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      '${task['date']} • ${task['location']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    Text(
                                      '${task['hours']} giờ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.apply(
                                            color: MinhColors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Iconsax.arrow_right_3),
                              ),
                            );
                          },
                        )),

                  SizedBox(height: MinhSizes.spaceBtwItems),

                  // Contributions
                  Text(
                    "Đóng góp",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: MinhSizes.spaceBtwItems / 2),
                  Obx(() => controller.contributions.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(MinhSizes.defaultSpace),
                          child: Text(
                            "Chưa có đóng góp nào",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.contributions.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: MinhSizes.spaceBtwItems / 2),
                          itemBuilder: (context, index) {
                            final contribution = controller.contributions[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  contribution['type'] == 'Shelter'
                                      ? Iconsax.home
                                      : Iconsax.box,
                                  color: MinhColors.primary,
                                ),
                                title: Text(contribution['title'] ?? ''),
                                subtitle: Text(
                                  '${contribution['date']} • ${contribution['location']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: Icon(Iconsax.arrow_right_3),
                              ),
                            );
                          },
                        )),

                  SizedBox(height: MinhSizes.spaceBtwSections * 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: MinhSizes.spaceBtwItems / 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall!.apply(
                color: color,
                fontWeightDelta: 2,
              ),
        ),
        SizedBox(height: MinhSizes.spaceBtwItems / 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: color.withOpacity(0.8),
              ),
        ),
      ],
    );
  }
}
