import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DonationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('donations');

  /// Get total money donations
  Future<double> getTotalMoneyDonations() async {
    try {
      final snapshot = await _collection
          .where('Type', isEqualTo: 'money')
          .where('Status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final amount = (doc.data()['Amount'] as num?)?.toDouble() ?? 0;
        total += amount;
      }
      return total;
    } catch (e) {
      print('Error getting total donations: $e');
      return 0;
    }
  }

  /// Get total time donated by user
  Future<double> getTotalTimeDonated(String userId) async {
    try {
      final snapshot = await _collection
          .where('Type', isEqualTo: 'time')
          .where('UserId', isEqualTo: userId)
          .where('Status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final hours = (doc.data()['Hours'] as num?)?.toDouble() ?? 0;
        total += hours;
      }
      return total;
    } catch (e) {
      print('Error getting total time: $e');
      return 0;
    }
  }

  /// Create money donation
  Future<String> createMoneyDonation({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final docRef = await _collection.add({
        'Type': 'money',
        'Amount': amount,
        'PaymentMethod': paymentMethod,
        'Status': 'pending',
        'UserId': _auth.currentUser?.uid,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  /// Create supplies donation
  Future<String> createSuppliesDonation({
    required String itemName,
    required int quantity,
    String? description,
  }) async {
    try {
      final docRef = await _collection.add({
        'Type': 'supplies',
        'ItemName': itemName,
        'Quantity': quantity,
        'Description': description,
        'Status': 'pending',
        'UserId': _auth.currentUser?.uid,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  /// Create time donation
  Future<String> createTimeDonation({
    required double hours,
    required DateTime date,
    String? description,
  }) async {
    try {
      final docRef = await _collection.add({
        'Type': 'time',
        'Hours': hours,
        'Date': Timestamp.fromDate(date),
        'Description': description,
        'Status': 'pending',
        'UserId': _auth.currentUser?.uid,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create time donation: $e');
    }
  }

  /// Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    try {
      await _collection.doc(donationId).update({
        'Status': status,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update donation: $e');
    }
  }
}

