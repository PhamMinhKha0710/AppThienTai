import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:flutter/services.dart';

/// Banner Remote Data Source
abstract class BannerRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAllBanners();
  Future<void> uploadBannerToFirestore(Map<String, dynamic> bannerData);
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final FirebaseFirestore _firestore;

  BannerRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> getAllBanners() async {
    try {
      final snapshot = await _firestore.collection("Banners").get();
      final list = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .where((data) => data['Active'] == true)
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw ServerFailure('Failed to get banners: ${e.message}');
    } on PlatformException catch (e) {
      throw ServerFailure('Platform error: ${e.message}');
    } catch (e) {
      throw UnknownFailure('Failed to get banners: ${e.toString()}');
    }
  }

  @override
  Future<void> uploadBannerToFirestore(Map<String, dynamic> bannerData) async {
    try {
      await _firestore.collection("Banners").add(bannerData);
    } on FirebaseException catch (e) {
      throw ServerFailure('Failed to upload banner: ${e.message}');
    } on PlatformException catch (e) {
      throw ServerFailure('Platform error: ${e.message}');
    } catch (e) {
      throw UnknownFailure('Failed to upload banner: ${e.toString()}');
    }
  }
}

