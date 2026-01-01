import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/controllers/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

/// About Screen - App info, terms, and privacy policy
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text('Về ứng dụng'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          children: [
            // App logo and name
            _buildAppHeader(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // App info
            Obx(() {
              if (controller.isLoadingAppInfo.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildAppInfoSection(context, isDark, controller.appInfo);
            }),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Links section
            _buildLinksSection(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Credits section
            _buildCreditsSection(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Copyright
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(MinhSizes.md),
          decoration: BoxDecoration(
            color: MinhColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MinhSizes.cardRadiusLg),
          ),
          child: Image.asset(
            'assets/logos/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Iconsax.shield_tick,
                size: 60,
                color: MinhColors.primary,
              );
            },
          ),
        ),
        const SizedBox(height: MinhSizes.spaceBtwItems),
        Text(
          'Cứu trợ Thiên tai',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: MinhSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MinhSizes.md,
            vertical: MinhSizes.sm / 2,
          ),
          decoration: BoxDecoration(
            color: MinhColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
          ),
          child: Text(
            'Phiên bản 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MinhColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(
      BuildContext context, bool isDark, Map<String, dynamic> appInfo) {
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
          Text(
            'Giới thiệu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: MinhSizes.sm),
          Text(
            appInfo['description'] ??
                'Ứng dụng hỗ trợ cứu trợ thiên tai, kết nối người cần giúp đỡ với tình nguyện viên và các tổ chức cứu trợ.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : MinhColors.darkGrey,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: MinhSizes.spaceBtwItems),
          const Divider(),
          const SizedBox(height: MinhSizes.spaceBtwItems),
          _buildInfoRow(
            context,
            icon: Iconsax.code,
            label: 'Phiên bản',
            value: appInfo['version'] ?? '1.0.0',
          ),
          _buildInfoRow(
            context,
            icon: Iconsax.chart,
            label: 'Build',
            value: appInfo['buildNumber'] ?? '1',
          ),
          _buildInfoRow(
            context,
            icon: Iconsax.user,
            label: 'Phát triển bởi',
            value: appInfo['developer'] ?? 'Development Team',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MinhSizes.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: MinhColors.darkerGrey),
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
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context, bool isDark) {
    return Container(
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
        children: [
          _buildLinkTile(
            context,
            icon: Iconsax.document_text,
            title: 'Điều khoản sử dụng',
            onTap: () => _launchUrl('https://cuutrobaolu.vn/terms'),
          ),
          const Divider(height: 1),
          _buildLinkTile(
            context,
            icon: Iconsax.shield_tick,
            title: 'Chính sách bảo mật',
            onTap: () => _launchUrl('https://cuutrobaolu.vn/privacy'),
          ),
          const Divider(height: 1),
          _buildLinkTile(
            context,
            icon: Iconsax.global,
            title: 'Website',
            onTap: () => _launchUrl('https://cuutrobaolu.vn'),
          ),
          const Divider(height: 1),
          _buildLinkTile(
            context,
            icon: Iconsax.star,
            title: 'Đánh giá ứng dụng',
            onTap: () {
              // TODO: Link to app store
              Get.snackbar(
                'Thông báo',
                'Cảm ơn bạn muốn đánh giá ứng dụng!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: MinhColors.primary),
      title: Text(title),
      trailing: const Icon(Iconsax.arrow_right_3),
      onTap: onTap,
    );
  }

  Widget _buildCreditsSection(BuildContext context, bool isDark) {
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
          Text(
            'Cảm ơn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: MinhSizes.sm),
          Text(
            'Ứng dụng được phát triển với sự hỗ trợ của:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : MinhColors.darkGrey,
                ),
          ),
          const SizedBox(height: MinhSizes.sm),
          _buildCreditItem('Flutter & Dart Team'),
          _buildCreditItem('Firebase'),
          _buildCreditItem('OpenStreetMap'),
          _buildCreditItem('Cộng đồng tình nguyện viên'),
        ],
      ),
    );
  }

  Widget _buildCreditItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MinhSizes.sm / 2),
      child: Row(
        children: [
          const Icon(Iconsax.heart, size: 14, color: Colors.red),
          const SizedBox(width: MinhSizes.sm),
          Text(
            name,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: MinhSizes.sm),
        Text(
          '© 2025 Cứu trợ Thiên tai',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MinhColors.darkerGrey,
              ),
        ),
        Text(
          'All rights reserved.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MinhColors.darkerGrey,
              ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mở đường link',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}




