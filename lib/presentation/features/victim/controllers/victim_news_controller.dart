import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/chatbot/MinhChatbotSuggestion.dart';
import 'package:iconsax/iconsax.dart';

class VictimNewsController extends GetxController {
  final selectedCategory = "Tất cả".obs;
  final searchQuery = "".obs;
  
  final categories = ["Tất cả", "Sơ tán", "Y tế cơ bản", "Từ chính quyền"];
  final allNews = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  void loadNews() {
    // TODO: Load from Firestore
    allNews.value = [
      {
        'title': 'Cách sơ tán khi bị cuốn lũ',
        'summary': 'Hướng dẫn chi tiết cách sơ tán an toàn khi gặp lũ lụt',
        'content': 'Khi gặp lũ lụt, bạn cần di chuyển đến nơi cao hơn ngay lập tức...',
        'category': 'Sơ tán',
        'image': 'https://via.placeholder.com/300',
      },
      {
        'title': 'Hướng dẫn sơ cứu cơ bản',
        'summary': 'Các bước sơ cứu cơ bản trong tình huống khẩn cấp',
        'content': 'Trong tình huống khẩn cấp, việc sơ cứu đúng cách có thể cứu sống...',
        'category': 'Y tế cơ bản',
        'image': 'https://via.placeholder.com/300',
      },
    ];
  }

  List<Map<String, dynamic>> get filteredNews {
    var filtered = List<Map<String, dynamic>>.from(allNews);

    // Filter by category
    if (selectedCategory.value != "Tất cả") {
      filtered = filtered.where((news) => 
        news['category'] == selectedCategory.value
      ).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((news) =>
        news['title'].toString().toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        news['summary'].toString().toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  void searchNews(String query) {
    searchQuery.value = query;
  }

  void showChatbot() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(MinhSizes.borderRadiusLg)),
        ),
        child: Column(
          children: [
            Text(
              "Chatbot hỗ trợ",
              style: Get.textTheme.headlineSmall,
            ),
            SizedBox(height: MinhSizes.spaceBtwItems),
            Expanded(
              child: ListView(
                children: [
                  MinhChatbotSuggestion(
                    text: "Hướng dẫn sơ cứu",
                    onTap: () {
                      // TODO: Handle chatbot query
                    },
                  ),
                  MinhChatbotSuggestion(
                    text: "Nơi trú ẩn gần nhất",
                    onTap: () {
                      // TODO: Handle chatbot query
                    },
                  ),
                  MinhChatbotSuggestion(
                    text: "Cách sơ tán",
                    onTap: () {
                      // TODO: Handle chatbot query
                    },
                  ),
                ],
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Nhập câu hỏi...",
                suffixIcon: IconButton(
                  icon: Icon(Iconsax.send_1),
                  onPressed: () {
                    // TODO: Send message to chatbot
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


