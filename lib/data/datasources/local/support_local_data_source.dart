import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:cuutrobaolu/data/models/support_faq_dto.dart';

/// Support Local Data Source Interface
abstract class SupportLocalDataSource {
  Future<List<SupportFaqDto>> getCachedFaqs();
  Future<void> cacheFaqs(List<SupportFaqDto> faqs);
  Future<void> clearFaqCache();
  Future<Map<String, dynamic>?> getCachedAppInfo();
  Future<void> cacheAppInfo(Map<String, dynamic> appInfo);
}

/// Support Local Data Source Implementation using GetStorage
class SupportLocalDataSourceImpl implements SupportLocalDataSource {
  final GetStorage _storage;
  static const String _faqCacheKey = 'support_faqs_cache';
  static const String _appInfoCacheKey = 'app_info_cache';
  static const String _faqCacheTimeKey = 'support_faqs_cache_time';
  static const Duration _cacheExpiration = Duration(hours: 24);

  SupportLocalDataSourceImpl({GetStorage? storage})
      : _storage = storage ?? GetStorage();

  @override
  Future<List<SupportFaqDto>> getCachedFaqs() async {
    try {
      final cacheTimeStr = _storage.read<String>(_faqCacheTimeKey);
      if (cacheTimeStr != null) {
        final cacheTime = DateTime.parse(cacheTimeStr);
        if (DateTime.now().difference(cacheTime) > _cacheExpiration) {
          // Cache expired
          await clearFaqCache();
          return [];
        }
      }

      final cachedData = _storage.read<String>(_faqCacheKey);
      if (cachedData == null) return [];

      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded
          .map((json) => SupportFaqDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheFaqs(List<SupportFaqDto> faqs) async {
    try {
      final jsonList = faqs.map((faq) => faq.toJson(includeId: true)).toList();
      await _storage.write(_faqCacheKey, jsonEncode(jsonList));
      await _storage.write(_faqCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Silently fail caching
    }
  }

  @override
  Future<void> clearFaqCache() async {
    await _storage.remove(_faqCacheKey);
    await _storage.remove(_faqCacheTimeKey);
  }

  @override
  Future<Map<String, dynamic>?> getCachedAppInfo() async {
    try {
      final cachedData = _storage.read<String>(_appInfoCacheKey);
      if (cachedData == null) return null;
      return jsonDecode(cachedData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheAppInfo(Map<String, dynamic> appInfo) async {
    try {
      await _storage.write(_appInfoCacheKey, jsonEncode(appInfo));
    } catch (e) {
      // Silently fail caching
    }
  }
}

