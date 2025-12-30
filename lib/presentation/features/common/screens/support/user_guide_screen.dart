import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// User Guide Screen - Step-by-step tutorials and feature explanations
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text('Hướng dẫn sử dụng'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            _buildIntroSection(context, isDark),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Guide sections
            _buildGuideSection(
              context,
              isDark,
              title: 'Bắt đầu sử dụng',
              icon: Iconsax.play_circle,
              color: Colors.blue,
              guides: [
                _GuideItem(
                  title: 'Đăng ký tài khoản',
                  description:
                      'Tạo tài khoản mới bằng email hoặc đăng nhập bằng Google.',
                  steps: [
                    'Nhấn "Đăng ký" trên màn hình chào mừng',
                    'Điền thông tin: họ tên, email, mật khẩu',
                    'Xác nhận email qua link được gửi',
                    'Hoàn tất thông tin cá nhân',
                  ],
                ),
                _GuideItem(
                  title: 'Cập nhật thông tin cá nhân',
                  description:
                      'Cập nhật ảnh đại diện, số điện thoại và địa chỉ.',
                  steps: [
                    'Vào Cài đặt > Hồ sơ',
                    'Nhấn vào thông tin cần sửa',
                    'Cập nhật và lưu thay đổi',
                  ],
                ),
              ],
            ),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            _buildGuideSection(
              context,
              isDark,
              title: 'Gửi yêu cầu cứu trợ',
              icon: Iconsax.message_add,
              color: Colors.green,
              guides: [
                _GuideItem(
                  title: 'Tạo yêu cầu cứu trợ mới',
                  description:
                      'Gửi yêu cầu khi bạn cần hỗ trợ về nhu yếu phẩm, y tế...',
                  steps: [
                    'Nhấn nút "Tạo yêu cầu" trên màn hình chính',
                    'Chọn loại yêu cầu (thực phẩm, y tế, sơ tán...)',
                    'Mô tả chi tiết tình trạng và nhu cầu',
                    'Xác nhận vị trí hiện tại',
                    'Gửi yêu cầu và chờ hỗ trợ',
                  ],
                ),
                _GuideItem(
                  title: 'Theo dõi yêu cầu',
                  description: 'Xem trạng thái và cập nhật của yêu cầu đã gửi.',
                  steps: [
                    'Vào Cài đặt > Yêu cầu của tôi',
                    'Nhấn vào yêu cầu để xem chi tiết',
                    'Trạng thái: Đang chờ → Đang xử lý → Hoàn thành',
                  ],
                ),
              ],
            ),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            _buildGuideSection(
              context,
              isDark,
              title: 'Chức năng SOS khẩn cấp',
              icon: Icons.sos,
              color: Colors.red,
              guides: [
                _GuideItem(
                  title: 'Gửi tín hiệu SOS',
                  description:
                      'Khi gặp nguy hiểm, gửi SOS để được hỗ trợ ngay lập tức.',
                  steps: [
                    'Nhấn giữ nút SOS trên màn hình chính',
                    'Xác nhận gửi tín hiệu khẩn cấp',
                    'Vị trí của bạn sẽ được gửi tự động',
                    'Tình nguyện viên gần nhất sẽ được thông báo',
                  ],
                ),
              ],
            ),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            _buildGuideSection(
              context,
              isDark,
              title: 'Xem cảnh báo & tin tức',
              icon: Iconsax.notification,
              color: Colors.orange,
              guides: [
                _GuideItem(
                  title: 'Nhận cảnh báo thiên tai',
                  description:
                      'Ứng dụng sẽ thông báo khi có cảnh báo trong khu vực của bạn.',
                  steps: [
                    'Bật thông báo trong Cài đặt > Thông báo',
                    'Cho phép quyền vị trí để nhận cảnh báo theo khu vực',
                    'Cảnh báo khẩn cấp sẽ có âm thanh và rung',
                  ],
                ),
                _GuideItem(
                  title: 'Xem bản đồ và điểm sơ tán',
                  description:
                      'Tìm điểm sơ tán, nơi phát hàng cứu trợ gần nhất.',
                  steps: [
                    'Vào tab Bản đồ',
                    'Xem các điểm được đánh dấu trên bản đồ',
                    'Nhấn vào điểm để xem thông tin chi tiết',
                    'Nhấn "Chỉ đường" để được dẫn đường',
                  ],
                ),
              ],
            ),
            const SizedBox(height: MinhSizes.spaceBtwSections),

            // Tips section
            _buildTipsSection(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(MinhSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinhColors.primary,
            MinhColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(MinhSizes.cardRadiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.book,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: MinhSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hướng dẫn sử dụng ứng dụng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tìm hiểu các tính năng chính của ứng dụng',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildGuideSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_GuideItem> guides,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MinhSizes.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: MinhSizes.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: MinhSizes.spaceBtwItems),
        ...guides.map((guide) => _buildGuideCard(context, isDark, guide, color)),
      ],
    );
  }

  Widget _buildGuideCard(
      BuildContext context, bool isDark, _GuideItem guide, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: MinhSizes.md,
            vertical: MinhSizes.sm / 2,
          ),
          childrenPadding: const EdgeInsets.only(
            left: MinhSizes.md,
            right: MinhSizes.md,
            bottom: MinhSizes.md,
          ),
          title: Text(
            guide.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            guide.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MinhColors.darkerGrey,
                ),
          ),
          children: [
            ...guide.steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: MinhSizes.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: MinhSizes.sm),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDark ? Colors.white70 : MinhColors.darkGrey,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(MinhSizes.md),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.lamp_on, color: Colors.amber),
              const SizedBox(width: MinhSizes.sm),
              Text(
                'Mẹo hữu ích',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: MinhSizes.sm),
          _buildTipItem('Luôn bật định vị để nhận cảnh báo chính xác'),
          _buildTipItem('Cập nhật thông tin liên lạc thường xuyên'),
          _buildTipItem('Kiểm tra pin điện thoại trước khi có bão'),
          _buildTipItem('Lưu số hotline cứu hộ: 114, 113, 115'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MinhSizes.sm / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.tick_circle, size: 16, color: Colors.amber),
          const SizedBox(width: MinhSizes.sm),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideItem {
  final String title;
  final String description;
  final List<String> steps;

  _GuideItem({
    required this.title,
    required this.description,
    required this.steps,
  });
}

