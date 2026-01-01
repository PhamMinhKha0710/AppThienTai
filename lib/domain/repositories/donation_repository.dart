import '../entities/donation_entity.dart';
import '../../core/constants/supply_categories.dart';

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
    String? alertId,
    String? province,
    String? district,
  });

  /// Tạo supplies donation
  Future<String> createSuppliesDonation({
    required String itemName,
    required int quantity,
    String? description,
    SupplyCategory? category,
    String? customCategory,
    String? alertId,
    String? province,
    String? district,
  });

  /// Tạo time donation
  Future<String> createTimeDonation({
    required double hours,
    required DateTime date,
    String? description,
    String? alertId,
    String? province,
    String? district,
  });

  /// Cập nhật donation status
  Future<void> updateDonationStatus(String donationId, DonationStatus status);

  /// Lấy danh sách quyên góp theo alert
  Future<List<DonationEntity>> getDonationsByAlert(String alertId);

  /// Lấy danh sách quyên góp theo khu vực
  Future<List<DonationEntity>> getDonationsByArea(
    String province,
    String? district,
  );
}


