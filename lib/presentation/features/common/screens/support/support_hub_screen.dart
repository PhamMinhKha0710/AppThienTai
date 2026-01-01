import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/faq_screen.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/contact_support_screen.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/user_guide_screen.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Support Hub Screen - Main entry point for support features
class SupportHubScreen extends StatelessWidget {
  const SupportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text('Trung tâm hỗ trợ'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeaderSection(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Support options grid
            _buildSupportOptionsGrid(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Quick contact section
            _buildQuickContactSection(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(MinhSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinhColors.primary,
            MinhColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MinhSizes.cardRadiusLg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MinhSizes.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
            ),
            child: const Icon(
              Iconsax.message_question,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: MinhSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chúng tôi có thể giúp gì?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tìm câu trả lời hoặc liên hệ hỗ trợ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptionsGrid(BuildContext context, bool isDark) {
    final options = [
      _SupportOption(
        icon: Iconsax.message_question,
        title: 'Câu hỏi thường gặp',
        subtitle: 'Tìm câu trả lời nhanh',
        color: Colors.blue,
        onTap: () => Get.to(() => const FaqScreen()),
      ),
      _SupportOption(
        icon: Iconsax.message_text,
        title: 'Liên hệ hỗ trợ',
        subtitle: 'Gửi yêu cầu hỗ trợ',
        color: Colors.green,
        onTap: () => Get.to(() => const ContactSupportScreen()),
      ),
      _SupportOption(
        icon: Iconsax.book,
        title: 'Hướng dẫn sử dụng',
        subtitle: 'Tìm hiểu tính năng',
        color: Colors.orange,
        onTap: () => Get.to(() => const UserGuideScreen()),
      ),
      _SupportOption(
        icon: Iconsax.info_circle,
        title: 'Về ứng dụng',
        subtitle: 'Thông tin & điều khoản',
        color: Colors.purple,
        onTap: () => Get.to(() => const AboutScreen()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: MinhSizes.gridViewSpacing,
        mainAxisSpacing: MinhSizes.gridViewSpacing,
        childAspectRatio: 1.1,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildSupportCard(context, option, isDark);
      },
    );
  }

  Widget _buildSupportCard(
      BuildContext context, _SupportOption option, bool isDark) {
    return InkWell(
      onTap: option.onTap,
      borderRadius: BorderRadius.circular(MinhSizes.cardRadiusMd),
      child: Container(
        padding: const EdgeInsets.all(MinhSizes.md),
        decoration: BoxDecoration(
          color: isDark ? MinhColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(MinhSizes.cardRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(MinhSizes.sm),
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
              ),
              child: Icon(
                option.icon,
                color: option.color,
                size: 32,
              ),
            ),
            const SizedBox(height: MinhSizes.sm),
            Text(
              option.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              option.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MinhColors.darkerGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(MinhSizes.md),
      decoration: BoxDecoration(
        color: isDark ? MinhColors.dark : Colors.white,
        borderRadius: BorderRadius.circular(MinhSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.call,
                color: MinhColors.primary,
                size: 20,
              ),
              const SizedBox(width: MinhSizes.sm),
              Text(
                'Liên hệ nhanh',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const Divider(height: MinhSizes.spaceBtwItems * 2),
          _buildContactItem(
            context,
            icon: Iconsax.call,
            label: 'Đường dây nóng',
            value: '1900-xxxx',
            isDark: isDark,
          ),
          const SizedBox(height: MinhSizes.spaceBtwItems / 2),
          _buildContactItem(
            context,
            icon: Iconsax.sms,
            label: 'Email hỗ trợ',
            value: 'support@cuutrobaolu.vn',
            isDark: isDark,
          ),
          const SizedBox(height: MinhSizes.spaceBtwItems / 2),
          _buildContactItem(
            context,
            icon: Iconsax.clock,
            label: 'Giờ làm việc',
            value: '24/7 (Khẩn cấp)',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: MinhColors.darkerGrey,
        ),
        const SizedBox(width: MinhSizes.sm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MinhColors.darkerGrey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _SupportOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}




