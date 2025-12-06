import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhRoundedContainer.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class MinhSingleAddress extends StatelessWidget {
  const MinhSingleAddress({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.selectAddress,
    this.title = '',
    this.description = '',
    this.date,
    this.status = RequestStatus.pending,
  });

  final String name;
  final String phone;
  final String address;
  final bool selectAddress;
  final RequestStatus status;

  // Các thuộc tính chưa sử dụng
  final String title;
  final String description;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);

    final (icon, color, text) = switch (status) {
      RequestStatus.pending => (
          Iconsax.timer_start,
          MinhColors.warning,
          status.viName
        ),
      RequestStatus.inProgress => (Iconsax.ship, MinhColors.primary, status.viName),
      RequestStatus.completed => (
          Iconsax.tick_circle,
          MinhColors.success,
          status.viName
        ),
      RequestStatus.cancelled => (
          Iconsax.close_circle,
          MinhColors.error,
          status.viName
        ),
    };

    return MinhRoundedContainer(
      width: double.infinity,
      showBorder: true,
      padding: const EdgeInsets.all(MinhSizes.md),
      margin: const EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      // Điều chỉnh màu nền và viền dựa trên trạng thái `selectAddress`
      backgroundColor: selectAddress
          ? MinhColors.primary.withOpacity(0.5)
          : Colors.transparent,
      borderColor: selectAddress
          ? Colors.transparent
          : isDark
              ? MinhColors.darkerGrey
              : MinhColors.grey,
      child: Stack(
        children: [
          // Icon check ở góc trên bên phải
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              selectAddress ? Iconsax.tick_circle5 : null,
              color: selectAddress
                  ? isDark
                      ? MinhColors.light
                      : MinhColors.dark
                  : null,
            ),
          ),
          // Bố cục thông tin địa chỉ
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên người dùng
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: MinhSizes.sm),

              // Số điện thoại
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Iconsax.call,
                      size: 19,
                      color:
                          isDark ? MinhColors.lightGrey : MinhColors.textSecondary),
                  const SizedBox(width: MinhSizes.spaceBtwItems / 2),
                  Text(phone, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
              const SizedBox(height: MinhSizes.sm),

              // Địa chỉ
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Iconsax.location,
                      size: 19,
                      color:
                          isDark ? MinhColors.lightGrey : MinhColors.textSecondary),
                  const SizedBox(width: MinhSizes.spaceBtwItems / 2),
                  Expanded(
                    child: ReadMoreText(
                      address,
                      trimLines: 1, // Số dòng tối đa để ẩn văn bản
                      // trimMode: TrimMode.Line,
                      trimMode: TrimMode.Length,
                      trimLength: 30,
                      trimCollapsedText: ' xem thêm',
                      trimExpandedText: ' ẩn bớt',
                      moreStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MinhColors.primary),
                      lessStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MinhColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MinhSizes.sm),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              if (title.isNotEmpty) const SizedBox(height: MinhSizes.sm),
              if (description.isNotEmpty)
                ReadMoreText(
                  description,
                  trimLines: 2,
                  colorClickableText: MinhColors.primary,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' xem thêm',
                  trimExpandedText: ' ẩn bớt',
                  moreStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  lessStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              if (description.isNotEmpty) const SizedBox(height: MinhSizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 19),
                      const SizedBox(width: MinhSizes.spaceBtwItems / 2),
                      Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.apply(color: color),
                      ),
                    ],
                  ),
                  if (date != null)
                    Text(
                      DateFormat.yMd().format(date!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
