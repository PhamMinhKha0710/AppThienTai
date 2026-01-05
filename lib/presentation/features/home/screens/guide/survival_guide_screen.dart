import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/data/DummyData/guide_data.dart';
import 'package:cuutrobaolu/presentation/features/home/models/guide_model.dart';
import 'package:cuutrobaolu/presentation/features/home/screens/guide/guide_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SurvivalGuideScreen extends StatelessWidget {
  const SurvivalGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = GuideData.guides;
    final categories = guides.map((e) => e.category).toSet().toList();

    return Scaffold(
      appBar: const MinhAppbar(
        title: Text("Cẩm nang sinh tồn"),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MinhSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar (visual only for now)
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm hướng dẫn...',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
                  ),
                ),
              ),
              const SizedBox(height: MinhSizes.spaceBtwSections),

              // Categories List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryGuides = guides.where((g) => g.category == category).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: MinhSizes.spaceBtwItems),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryGuides.length,
                        separatorBuilder: (_, __) => const SizedBox(height: MinhSizes.spaceBtwItems),
                        itemBuilder: (context, guideIndex) {
                          final guide = categoryGuides[guideIndex];
                          return _buildGuideCard(context, guide);
                        },
                      ),
                      const SizedBox(height: MinhSizes.spaceBtwSections),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, GuideModel guide) {
    return GestureDetector(
      onTap: () => Get.to(() => GuideDetailScreen(guide: guide)),
      child: Container(
        padding: const EdgeInsets.all(MinhSizes.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Icon Placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
              ),
              child: const Icon(Iconsax.book, color: Colors.blue),
            ),
            const SizedBox(width: MinhSizes.spaceBtwItems),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (guide.isOffline)
                        const Icon(Iconsax.flash_circle, size: 14, color: Colors.green),
                      if (guide.isOffline)
                        const SizedBox(width: 4),
                      Text(
                        guide.isOffline ? "Xem offline" : "Cần mạng",
                        style: Theme.of(context).textTheme.labelMedium?.apply(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 18),
          ],
        ),
      ),
    );
  }
}
