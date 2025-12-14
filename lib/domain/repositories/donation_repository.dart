import '../entities/donation_entity.dart';

/// Donation Repository Interface
/// Định nghĩa contract cho donation operations
abstract class DonationRepository {
  /// Lấy tổng tiền quyên góp
  Future<double> getTotalMoneyDonations();

  /// Lấy tổng thời gian quyên góp của user
  Future<double> getTotalTimeDonated(String userId);

  /// Tạo money donation
  Future<String> createMoneyDonation({
    required double amount,
    required String paymentMethod,
  });

  /// Tạo supplies donation
  Future<String> createSuppliesDonation({
    required String itemName,
    required int quantity,
    String? description,
  });

  /// Tạo time donation
  Future<String> createTimeDonation({
    required double hours,
    required DateTime date,
    String? description,
  });

  /// Cập nhật donation status
  Future<void> updateDonationStatus(String donationId, DonationStatus status);
}


