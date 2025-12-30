import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/domain/entities/support_faq_entity.dart';
import 'package:cuutrobaolu/presentation/features/common/screens/support/controllers/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// FAQ Screen - Displays frequently asked questions with search and categories
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MinhAppbar(
        title: const Text('Câu hỏi thường gặp'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(MinhSizes.defaultSpace),
            child: _buildSearchBar(context, controller, isDark),
          ),

          // Category tabs
          _buildCategoryTabs(context, controller),
          const SizedBox(height: MinhSizes.spaceBtwItems),

          // FAQ list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingFaqs.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final faqs = controller.filteredFaqs;
              if (faqs.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: MinhSizes.defaultSpace,
                ),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return _FaqExpansionTile(
                    faq: faqs[index],
                    isDark: isDark,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, SupportController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? MinhColors.dark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
      ),
      child: TextField(
        onChanged: controller.searchFaqs,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm câu hỏi...',
          prefixIcon: const Icon(Iconsax.search_normal),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: () {
                  controller.searchFaqs('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: MinhSizes.md,
            vertical: MinhSizes.md,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context, SupportController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
      child: Obx(() => Row(
            children: [
              _CategoryChip(
                label: 'Tất cả',
                isSelected: controller.selectedCategory.value == null,
                onTap: () => controller.selectCategory(null),
              ),
              const SizedBox(width: MinhSizes.spaceBtwItems / 2),
              ...FaqCategory.values.map((category) => Padding(
                    padding: const EdgeInsets.only(
                        right: MinhSizes.spaceBtwItems / 2),
                    child: _CategoryChip(
                      label: category.label,
                      isSelected:
                          controller.selectedCategory.value == category,
                      onTap: () => controller.selectCategory(category),
                    ),
                  )),
            ],
          )),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 64,
            color: MinhColors.darkerGrey,
          ),
          const SizedBox(height: MinhSizes.spaceBtwItems),
          Text(
            'Không tìm thấy câu hỏi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: MinhSizes.sm),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MinhColors.darkerGrey,
                ),
          ),
        ],
      ),
    );
  }
}

/// Category filter chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MinhSizes.md,
          vertical: MinhSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? MinhColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
          border: Border.all(
            color: isSelected ? MinhColors.primary : MinhColors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : MinhColors.darkerGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// FAQ expansion tile widget
class _FaqExpansionTile extends StatelessWidget {
  final SupportFaqEntity faq;
  final bool isDark;

  const _FaqExpansionTile({
    required this.faq,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
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
          leading: Container(
            padding: const EdgeInsets.all(MinhSizes.sm),
            decoration: BoxDecoration(
              color: _getCategoryColor(faq.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(MinhSizes.borderRadiusSm),
            ),
            child: Icon(
              _getCategoryIcon(faq.category),
              color: _getCategoryColor(faq.category),
              size: 20,
            ),
          ),
          title: Text(
            faq.question,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(
              horizontal: MinhSizes.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getCategoryColor(faq.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              faq.category.label,
              style: TextStyle(
                fontSize: 10,
                color: _getCategoryColor(faq.category),
              ),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : MinhColors.darkGrey,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(FaqCategory category) {
    switch (category) {
      case FaqCategory.general:
        return Colors.blue;
      case FaqCategory.emergency:
        return Colors.red;
      case FaqCategory.features:
        return Colors.orange;
      case FaqCategory.account:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(FaqCategory category) {
    switch (category) {
      case FaqCategory.general:
        return Iconsax.message_question;
      case FaqCategory.emergency:
        return Iconsax.warning_2;
      case FaqCategory.features:
        return Iconsax.mobile;
      case FaqCategory.account:
        return Iconsax.user;
    }
  }
}

