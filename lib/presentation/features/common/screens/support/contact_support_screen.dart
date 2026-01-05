import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/domain/entities/support_contact_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/controllers/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Contact Support Screen - Form to submit support requests
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text('Liên hệ hỗ trợ'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              _buildHeaderInfo(context, isDark),
              const SizedBox(height: MinhSizes.spaceBtwSections),

              // Form fields
              Text(
                'Thông tin liên hệ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: MinhSizes.spaceBtwItems),

              // Name field
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Iconsax.user),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: MinhSizes.spaceBtwInputFields),

              // Email field
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Iconsax.sms),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: MinhSizes.spaceBtwInputFields),

              // Subject dropdown
              Text(
                'Chủ đề',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: MinhSizes.spaceBtwItems),
              Obx(() => Wrap(
                    spacing: MinhSizes.sm,
                    runSpacing: MinhSizes.sm,
                    children: ContactSubject.values.map((subject) {
                      final isSelected =
                          controller.selectedSubject.value == subject;
                      return ChoiceChip(
                        label: Text(subject.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectSubject(subject);
                          }
                        },
                        selectedColor: MinhColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? MinhColors.primary
                              : (isDark ? Colors.white70 : MinhColors.darkGrey),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: MinhSizes.spaceBtwInputFields),

              // Message field
              Text(
                'Nội dung',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: MinhSizes.spaceBtwItems),
              TextFormField(
                controller: controller.messageController,
                maxLines: 5,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'Mô tả chi tiết vấn đề của bạn...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  if (value.length < 10) {
                    return 'Nội dung quá ngắn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: MinhSizes.spaceBtwSections),

              // Submit button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final success = await controller.submitContact();
                                if (success) {
                                  MinhLoaders.successSnackBar(
                                    title: 'Thành công',
                                    message:
                                        'Yêu cầu hỗ trợ đã được gửi. Chúng tôi sẽ phản hồi sớm!',
                                  );
                                  Get.back();
                                }
                              }
                            },
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Gửi yêu cầu'),
                    ),
                  )),
              const SizedBox(height: MinhSizes.spaceBtwSections),

              // Alternative contact info
              _buildAlternativeContact(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(MinhSizes.md),
      decoration: BoxDecoration(
        color: MinhColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            color: MinhColors.primary,
          ),
          const SizedBox(width: MinhSizes.sm),
          Expanded(
            child: Text(
              'Điền đầy đủ thông tin để chúng tôi hỗ trợ bạn tốt nhất',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MinhColors.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeContact(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(MinhSizes.md),
      decoration: BoxDecoration(
        color: isDark ? MinhColors.dark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liên hệ khác',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: MinhSizes.sm),
          _buildContactRow(
            context,
            icon: Iconsax.call,
            label: 'Đường dây nóng',
            value: '1900-xxxx',
          ),
          const SizedBox(height: MinhSizes.sm / 2),
          _buildContactRow(
            context,
            icon: Iconsax.sms,
            label: 'Email',
            value: 'support@cuutrobaolu.vn',
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MinhColors.darkerGrey),
        const SizedBox(width: MinhSizes.sm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MinhColors.darkerGrey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}


















