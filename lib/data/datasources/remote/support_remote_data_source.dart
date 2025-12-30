import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/domain/entities/support_faq_entity.dart';
import 'package:cuutrobaolu/data/models/support_faq_dto.dart';
import 'package:cuutrobaolu/data/models/support_contact_dto.dart';

/// Support Remote Data Source Interface
abstract class SupportRemoteDataSource {
  Future<List<SupportFaqDto>> getFaqs();
  Future<List<SupportFaqDto>> getFaqsByCategory(FaqCategory category);
  Future<String> submitContactForm(SupportContactDto dto);
  Future<List<SupportContactDto>> getContactHistory(String userId);
  Future<Map<String, dynamic>> getAppInfo();
}

/// Support Remote Data Source Implementation
class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final FirebaseFirestore _firestore;

  SupportRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _faqCollection =>
      _firestore.collection('support_faqs');

  CollectionReference<Map<String, dynamic>> get _contactCollection =>
      _firestore.collection('support_contacts');

  CollectionReference<Map<String, dynamic>> get _appInfoCollection =>
      _firestore.collection('app_config');

  @override
  Future<List<SupportFaqDto>> getFaqs() async {
    try {
      final snapshot = await _faqCollection
          .where('IsActive', isEqualTo: true)
          .orderBy('Order')
          .get();

      return snapshot.docs
          .map((doc) => SupportFaqDto.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch FAQs: ${e.toString()}');
    }
  }

  @override
  Future<List<SupportFaqDto>> getFaqsByCategory(FaqCategory category) async {
    try {
      final snapshot = await _faqCollection
          .where('IsActive', isEqualTo: true)
          .where('Category', isEqualTo: category.name)
          .orderBy('Order')
          .get();

      return snapshot.docs
          .map((doc) => SupportFaqDto.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch FAQs by category: ${e.toString()}');
    }
  }

  @override
  Future<String> submitContactForm(SupportContactDto dto) async {
    try {
      final docRef = await _contactCollection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw ServerFailure('Failed to submit contact form: ${e.toString()}');
    }
  }

  @override
  Future<List<SupportContactDto>> getContactHistory(String userId) async {
    try {
      final snapshot = await _contactCollection
          .where('UserId', isEqualTo: userId)
          .orderBy('CreatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SupportContactDto.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch contact history: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getAppInfo() async {
    try {
      final doc = await _appInfoCollection.doc('app_info').get();
      if (!doc.exists) {
        return _defaultAppInfo;
      }
      return doc.data() ?? _defaultAppInfo;
    } catch (e) {
      // Return default info if Firestore fails
      return _defaultAppInfo;
    }
  }

  Map<String, dynamic> get _defaultAppInfo => {
        'appName': 'Cứu trợ Thiên tai',
        'version': '1.0.0',
        'buildNumber': '1',
        'description': 'Ứng dụng hỗ trợ cứu trợ thiên tai',
        'developer': 'Development Team',
        'email': 'support@cuutrobaolu.vn',
        'phone': '1900-xxxx',
        'website': 'https://cuutrobaolu.vn',
        'termsUrl': 'https://cuutrobaolu.vn/terms',
        'privacyUrl': 'https://cuutrobaolu.vn/privacy',
        'copyright': '© 2025 Cứu trợ Thiên tai. All rights reserved.',
      };
}

