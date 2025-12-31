import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/victim/controllers/victim_news_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VictimNewsScreen extends StatelessWidget {
  const VictimNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VictimNewsController());

    return Scaffold(
      appBar: MinhAppbar(
        title: Text("Tin tức & Hướng dẫn"),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm hướng dẫn...",
                prefixIcon: Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                ),
              ),
              onChanged: (value) => controller.searchNews(value),
            ),
          ),

          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Obx(() {
                  final isSelected = controller.selectedCategory.value == category;
                  return Padding(
                    padding: EdgeInsets.only(right: MinhSizes.spaceBtwItems),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.selectedCategory.value = category;
                      },
                    ),
                  );
                });
              },
            ),
          ),

          SizedBox(height: MinhSizes.spaceBtwItems),

          // News list
          Expanded(
            child: Obx(() {
              final news = controller.filteredNews;
              return news.isEmpty
                  ? Center(
                      child: Text("Không có tin tức nào"),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: MinhSizes.defaultSpace,
                        right: MinhSizes.defaultSpace,
                        bottom: 100, // Space for SOS button
                      ),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final article = news[index];
                        return _NewsCard(article: article);
                      },
                    );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showChatbot(),
        backgroundColor: MinhColors.primary,
        child: Icon(Iconsax.message_question),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Map<String, dynamic> article;

  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
      child: InkWell(
        onTap: () {
          Get.dialog(
            Dialog(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(MinhSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['title'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: MinhSizes.spaceBtwItems),
                      if (article['image'] != null)
                        Image.network(article['image']),
                      SizedBox(height: MinhSizes.spaceBtwItems),
                      Text(
                        article['content'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: MinhSizes.spaceBtwItems),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Iconsax.share),
                            onPressed: () {
                              // Share functionality
                            },
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Đóng'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(MinhSizes.defaultSpace),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article['image'] != null)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                    image: DecorationImage(
                      image: NetworkImage(article['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (article['image'] != null)
                SizedBox(width: MinhSizes.spaceBtwItems),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: MinhSizes.spaceBtwItems / 2),
                    Text(
                      article['summary'],
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: MinhSizes.spaceBtwItems / 2),
                    Text(
                      article['category'],
                      style: Theme.of(context).textTheme.labelSmall?.apply(
                        color: MinhColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

