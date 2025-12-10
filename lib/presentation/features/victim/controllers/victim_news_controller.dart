import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/chatbot/MinhChatbotSuggestion.dart';
import 'package:cuutrobaolu/data/repositories/news/news_repository.dart';
import 'package:iconsax/iconsax.dart';

class VictimNewsController extends GetxController {
  final NewsRepository _newsRepo = NewsRepository();

  final selectedCategory = "Tất cả".obs;
  final searchQuery = "".obs;
  final isLoading = false.obs;
  
  final categories = ["Tất cả", "Sơ tán", "Y tế cơ bản", "Từ chính quyền"];
  final allNews = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  Future<void> loadNews() async {
    isLoading.value = true;
    try {
      if (selectedCategory.value == "Tất cả") {
        _newsRepo.getAllNews().listen((news) {
          allNews.value = news.map((item) => _formatNews(item)).toList();
        });
      } else {
        _newsRepo.getNewsByCategory(selectedCategory.value).listen((news) {
          allNews.value = news.map((item) => _formatNews(item)).toList();
        });
      }
    } catch (e) {
      print('Error loading news: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _formatNews(Map<String, dynamic> news) {
    return {
      'id': news['id'],
      'title': news['Title'] ?? news['title'] ?? '',
      'summary': news['Summary'] ?? news['summary'] ?? news['Content'] ?? '',
      'content': news['Content'] ?? news['content'] ?? '',
      'category': news['Category'] ?? news['category'] ?? 'Khác',
      'image': news['ImageUrl'] ?? news['image'] ?? news['Image'] ?? '',
      'createdAt': news['CreatedAt'],
    };
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

  void onCategoryChanged(String category) {
    selectedCategory.value = category;
    loadNews();
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
