import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/repositories/donation_repository.dart';
import '../../../domain/entities/donation_entity.dart';
import '../../models/donation_dto.dart';

class DonationRepositoryImpl implements DonationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DonationRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('donations');

  @override
  Future<double> getTotalMoneyDonations() async {
    try {
      final snapshot = await _collection
          .where('Type', isEqualTo: 'money')
          .where('Status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final dto = DonationDto.fromSnapshot(doc);
        total += dto.amount ?? 0;
      }
      return total;
    } catch (e) {
      print('Error getting total donations: $e');
      return 0;
    }
  }

  @override
  Future<double> getTotalTimeDonated(String userId) async {
    try {
      final snapshot = await _collection
          .where('Type', isEqualTo: 'time')
          .where('UserId', isEqualTo: userId)
          .where('Status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final dto = DonationDto.fromSnapshot(doc);
        total += dto.hours ?? 0;
      }
      return total;
    } catch (e) {
      print('Error getting total time: $e');
      return 0;
    }
  }

  @override
  Future<String> createMoneyDonation({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final entity = DonationEntity(
        id: '', // Will be set by Firestore
        type: DonationType.money,
        status: DonationStatus.pending,
        userId: _auth.currentUser?.uid,
        createdAt: DateTime.now(),
        amount: amount,
        paymentMethod: paymentMethod,
      );
      final dto = DonationDto.fromEntity(entity);
      final docRef = await _collection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  @override
  Future<String> createSuppliesDonation({
    required String itemName,
    required int quantity,
    String? description,
  }) async {
    try {
      final entity = DonationEntity(
        id: '', // Will be set by Firestore
        type: DonationType.supplies,
        status: DonationStatus.pending,
        userId: _auth.currentUser?.uid,
        createdAt: DateTime.now(),
        itemName: itemName,
        quantity: quantity,
        description: description,
      );
      final dto = DonationDto.fromEntity(entity);
      final docRef = await _collection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  @override
  Future<String> createTimeDonation({
    required double hours,
    required DateTime date,
    String? description,
  }) async {
    try {
      final entity = DonationEntity(
        id: '', // Will be set by Firestore
        type: DonationType.time,
        status: DonationStatus.pending,
        userId: _auth.currentUser?.uid,
        createdAt: DateTime.now(),
        hours: hours,
        date: date,
        description: description,
      );
      final dto = DonationDto.fromEntity(entity);
      final docRef = await _collection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create time donation: $e');
    }
  }

  @override
  Future<void> updateDonationStatus(String donationId, DonationStatus status) async {
    try {
      await _collection.doc(donationId).update({
        'Status': status.name,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update donation: $e');
    }
  }
}






