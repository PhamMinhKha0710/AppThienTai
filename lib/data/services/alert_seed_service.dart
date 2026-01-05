import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';

/// Service để seed dữ liệu mẫu cảnh báo vào Firestore
class AlertSeedService {
  final AlertRepository _alertRepo = getIt<AlertRepository>();

  /// Seed tất cả alerts mẫu vào Firestore
  Future<void> seedAlerts() async {
    try {
      final alerts = _generateSampleAlerts();
      
      print('[ALERT_SEED] Bắt đầu seed ${alerts.length} cảnh báo...');
      
      for (var alert in alerts) {
        await _alertRepo.createAlert(alert);
        print('[ALERT_SEED] Đã tạo cảnh báo: ${alert.title}');
      }
      
      print('[ALERT_SEED] Hoàn thành seed dữ liệu cảnh báo!');
    } catch (e) {
      print('[ALERT_SEED] Lỗi khi seed dữ liệu: $e');
      rethrow;
    }
  }

  /// Tạo danh sách alerts mẫu
  List<AlertEntity> _generateSampleAlerts() {
    final now = DateTime.now();
    final alerts = <AlertEntity>[];

    // ============================================
    // CẢNH BÁO CHO NẠN NHÂN (5-7 alerts)
    // ============================================

    // 1. Cảnh báo lũ lụt - Critical
    alerts.add(AlertEntity(
      id: '',
      title: 'Cảnh báo lũ lụt nghiêm trọng tại khu vực miền Trung',
      content:
          'Lũ lụt đang diễn ra tại các tỉnh miền Trung. Mực nước dâng cao, nguy hiểm đến tính mạng. Người dân cần di chuyển đến nơi an toàn ngay lập tức. Tránh xa các khu vực ngập nước, không đi qua cầu, đường ngập.',
      severity: AlertSeverity.critical,
      alertType: AlertType.disaster,
      targetAudience: TargetAudience.victims,
      lat: 16.0678, // Đà Nẵng
      lng: 108.2208,
      location: 'Khu vực miền Trung, Đà Nẵng',
      province: 'Đà Nẵng',
      district: 'Hải Châu',
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.add(const Duration(days: 3)),
      safetyGuide:
          '1. Di chuyển đến nơi cao ráo\n2. Không đi qua vùng ngập nước\n3. Tắt nguồn điện khi nước vào nhà\n4. Chuẩn bị đồ dùng cần thiết',
    ));

    // 2. Cảnh báo bão - High
    alerts.add(AlertEntity(
      id: '',
      title: 'Bão số 5 đang tiến vào đất liền',
      content:
          'Bão số 5 với sức gió mạnh đang tiến vào đất liền. Dự kiến đổ bộ vào đêm nay. Người dân cần chuẩn bị sẵn sàng, cố định đồ đạc, tránh ra ngoài khi bão đổ bộ.',
      severity: AlertSeverity.high,
      alertType: AlertType.disaster,
      targetAudience: TargetAudience.victims,
      lat: 15.8780, // Quảng Nam
      lng: 108.3475,
      location: 'Khu vực Quảng Nam, Quảng Ngãi',
      province: 'Quảng Nam',
      district: 'Tam Kỳ',
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 5)),
      expiresAt: now.add(const Duration(days: 2)),
      safetyGuide:
          '1. Cố định cửa, mái nhà\n2. Dự trữ nước và thực phẩm\n3. Tránh ra ngoài khi bão\n4. Theo dõi thông tin từ cơ quan chức năng',
    ));

    // 3. Cảnh báo mưa lớn - Medium
    alerts.add(AlertEntity(
      id: '',
      title: 'Cảnh báo mưa lớn kéo dài',
      content:
          'Dự báo mưa lớn sẽ kéo dài trong 24 giờ tới. Nguy cơ ngập lụt tại các khu vực trũng thấp. Người dân cần đề phòng, chuẩn bị phương án di chuyển nếu cần.',
      severity: AlertSeverity.medium,
      alertType: AlertType.weather,
      targetAudience: TargetAudience.victims,
      lat: 10.7769, // TP.HCM
      lng: 106.7009,
      location: 'Khu vực TP. Hồ Chí Minh',
      province: 'TP. Hồ Chí Minh',
      district: 'Quận 1',
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(days: 1)),
    ));

    // 4. Cảnh báo sơ tán - Critical
    alerts.add(AlertEntity(
      id: '',
      title: 'CẢNH BÁO SƠ TÁN KHẨN CẤP - Khu vực ven sông',
      content:
          'Mực nước sông đang dâng cao nhanh, vượt mức báo động 3. Người dân tại khu vực ven sông cần sơ tán ngay lập tức đến các điểm sơ tán an toàn. Không được ở lại nhà.',
      severity: AlertSeverity.critical,
      alertType: AlertType.evacuation,
      targetAudience: TargetAudience.victims,
      lat: 16.0678,
      lng: 108.2208,
      location: 'Khu vực ven sông Hàn, Đà Nẵng',
      province: 'Đà Nẵng',
      district: 'Thanh Khê',
      radiusKm: 5.0,
      isActive: true,
      createdAt: now.subtract(const Duration(minutes: 30)),
      expiresAt: now.add(const Duration(hours: 12)),
      safetyGuide:
          '1. Sơ tán ngay lập tức\n2. Mang theo giấy tờ quan trọng\n3. Đến điểm sơ tán: Trường THCS Nguyễn Du\n4. Liên hệ: 1900-xxxx',
    ));

    // 5. Điểm phân phát cứu trợ - Low
    alerts.add(AlertEntity(
      id: '',
      title: 'Điểm phân phát cứu trợ tại Trường THCS Nguyễn Du',
      content:
          'Điểm phân phát cứu trợ đang hoạt động tại Trường THCS Nguyễn Du. Người dân có thể đến nhận nước uống, lương thực, thuốc men. Thời gian: 7h-18h hàng ngày.',
      severity: AlertSeverity.low,
      alertType: AlertType.resource,
      targetAudience: TargetAudience.victims,
      lat: 16.0700,
      lng: 108.2300,
      location: 'Trường THCS Nguyễn Du, Đà Nẵng',
      province: 'Đà Nẵng',
      district: 'Hải Châu',
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 3)),
      expiresAt: now.add(const Duration(days: 7)),
    ));

    // 6. Cảnh báo theo vị trí - Location Based
    alerts.add(AlertEntity(
      id: '',
      title: 'Cảnh báo sạt lở đất tại khu vực núi',
      content:
          'Nguy cơ sạt lở đất cao tại khu vực núi do mưa lớn kéo dài. Người dân sống gần sườn núi cần đề phòng, chuẩn bị sơ tán nếu cần.',
      severity: AlertSeverity.high,
      alertType: AlertType.disaster,
      targetAudience: TargetAudience.locationBased,
      lat: 16.1000,
      lng: 108.2500,
      location: 'Khu vực núi Bà Nà, Đà Nẵng',
      province: 'Đà Nẵng',
      district: 'Hòa Vang',
      radiusKm: 10.0,
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 4)),
      expiresAt: now.add(const Duration(days: 2)),
    ));

    // ============================================
    // CẢNH BÁO CHO TÌNH NGUYỆN VIÊN (5-7 alerts)
    // ============================================

    // 7. Nhiệm vụ cứu trợ khẩn cấp - Critical
    alerts.add(AlertEntity(
      id: '',
      title: 'CẦN TÌNH NGUYỆN VIÊN CỨU TRỢ KHẨN CẤP',
      content:
          'Cần 20 tình nguyện viên hỗ trợ cứu trợ tại khu vực ngập lụt Đà Nẵng. Yêu cầu: có kinh nghiệm, sức khỏe tốt. Thời gian: ngay lập tức. Liên hệ: 0901-234-567.',
      severity: AlertSeverity.critical,
      alertType: AlertType.general,
      targetAudience: TargetAudience.volunteers,
      lat: 16.0678,
      lng: 108.2208,
      location: 'Khu vực ngập lụt, Đà Nẵng',
      province: 'Đà Nẵng',
      district: 'Hải Châu',
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(hours: 24)),
    ));

    // 8. Thông báo họp tình nguyện viên - Low
    alerts.add(AlertEntity(
      id: '',
      title: 'Họp tổng kết hoạt động cứu trợ',
      content:
          'Thông báo họp tổng kết hoạt động cứu trợ tháng này. Thời gian: 19h00 ngày mai. Địa điểm: Trung tâm điều phối cứu trợ. Vui lòng có mặt đúng giờ.',
      severity: AlertSeverity.low,
      alertType: AlertType.general,
      targetAudience: TargetAudience.volunteers,
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 6)),
      expiresAt: now.add(const Duration(days: 1)),
    ));

    // 9. Cần hỗ trợ khu vực - High
    alerts.add(AlertEntity(
      id: '',
      title: 'Cần hỗ trợ phân phát cứu trợ tại Quảng Nam',
      content:
          'Cần tình nguyện viên hỗ trợ phân phát cứu trợ tại Quảng Nam. Công việc: phân phát nước, lương thực, thuốc men. Thời gian: 2 ngày. Đăng ký: 0902-345-678.',
      severity: AlertSeverity.high,
      alertType: AlertType.resource,
      targetAudience: TargetAudience.volunteers,
      lat: 15.8780,
      lng: 108.3475,
      location: 'Quảng Nam',
      province: 'Quảng Nam',
      district: 'Tam Kỳ',
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 3)),
      expiresAt: now.add(const Duration(days: 2)),
    ));

    // 10. Cảnh báo chung cho tình nguyện viên - Medium
    alerts.add(AlertEntity(
      id: '',
      title: 'Lưu ý an toàn cho tình nguyện viên',
      content:
          'Khi tham gia cứu trợ, tình nguyện viên cần tuân thủ các quy định an toàn: mặc đồ bảo hộ, không đi vào vùng nguy hiểm, luôn có người hỗ trợ.',
      severity: AlertSeverity.medium,
      alertType: AlertType.general,
      targetAudience: TargetAudience.volunteers,
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 8)),
      expiresAt: now.add(const Duration(days: 5)),
      safetyGuide:
          '1. Mặc đồ bảo hộ đầy đủ\n2. Không đi một mình\n3. Tuân thủ hướng dẫn\n4. Báo cáo ngay khi có sự cố',
    ));

    // 11. Nhiệm vụ cứu trợ tiếp theo - High
    alerts.add(AlertEntity(
      id: '',
      title: 'Chuẩn bị nhiệm vụ cứu trợ tuần tới',
      content:
          'Chuẩn bị nhiệm vụ cứu trợ tại khu vực mới. Cần 15 tình nguyện viên. Thời gian: tuần tới. Vui lòng đăng ký trước ngày mai.',
      severity: AlertSeverity.high,
      alertType: AlertType.general,
      targetAudience: TargetAudience.volunteers,
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 12)),
      expiresAt: now.add(const Duration(days: 7)),
    ));

    // ============================================
    // CẢNH BÁO CHO TẤT CẢ (3-4 alerts)
    // ============================================

    // 12. Thông báo chung - Medium
    alerts.add(AlertEntity(
      id: '',
      title: 'Thông báo về hệ thống cảnh báo thiên tai',
      content:
          'Hệ thống cảnh báo thiên tai đã được kích hoạt. Người dân và tình nguyện viên vui lòng theo dõi thông tin thường xuyên để cập nhật tình hình.',
      severity: AlertSeverity.medium,
      alertType: AlertType.general,
      targetAudience: TargetAudience.all,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 1)),
      expiresAt: null, // Không hết hạn
    ));

    // 13. Cảnh báo thiên tai chung - High
    alerts.add(AlertEntity(
      id: '',
      title: 'Cảnh báo thiên tai mùa mưa bão',
      content:
          'Mùa mưa bão đang đến. Người dân cần chuẩn bị sẵn sàng, theo dõi dự báo thời tiết, chuẩn bị đồ dùng cần thiết. Tình nguyện viên sẵn sàng hỗ trợ khi cần.',
      severity: AlertSeverity.high,
      alertType: AlertType.disaster,
      targetAudience: TargetAudience.all,
      isActive: true,
      createdAt: now.subtract(const Duration(hours: 10)),
      expiresAt: now.add(const Duration(days: 30)),
    ));

    // 14. Thông báo về ứng dụng - Low
    alerts.add(AlertEntity(
      id: '',
      title: 'Hướng dẫn sử dụng ứng dụng cứu trợ',
      content:
          'Ứng dụng cung cấp các tính năng: cảnh báo thiên tai, yêu cầu cứu trợ, bản đồ an toàn. Vui lòng cập nhật ứng dụng để nhận các tính năng mới nhất.',
      severity: AlertSeverity.low,
      alertType: AlertType.general,
      targetAudience: TargetAudience.all,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 2)),
      expiresAt: null, // Không hết hạn
    ));

    // ============================================
    // CẢNH BÁO ĐÃ HẾT HẠN (cho tab Lịch sử) (2-3 alerts)
    // ============================================

    // 15. Cảnh báo đã hết hạn - Expired
    alerts.add(AlertEntity(
      id: '',
      title: 'Cảnh báo bão số 4 đã qua',
      content:
          'Bão số 4 đã đổ bộ và qua khỏi khu vực. Tình hình đã ổn định. Người dân có thể trở về nhà và tiếp tục cuộc sống bình thường.',
      severity: AlertSeverity.medium,
      alertType: AlertType.disaster,
      targetAudience: TargetAudience.victims,
      lat: 15.8780,
      lng: 108.3475,
      location: 'Quảng Nam',
      province: 'Quảng Nam',
      district: 'Tam Kỳ',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 5)),
      expiresAt: now.subtract(const Duration(days: 1)), // Đã hết hạn
    ));

    // 16. Cảnh báo đã hết hạn - Expired
    alerts.add(AlertEntity(
      id: '',
      title: 'Hoàn thành nhiệm vụ cứu trợ tuần trước',
      content:
          'Nhiệm vụ cứu trợ tại khu vực A đã hoàn thành. Cảm ơn các tình nguyện viên đã tham gia. Tổng kết sẽ được gửi qua email.',
      severity: AlertSeverity.low,
      alertType: AlertType.general,
      targetAudience: TargetAudience.volunteers,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 7)),
      expiresAt: now.subtract(const Duration(days: 2)), // Đã hết hạn
    ));

    // 17. Cảnh báo đã hết hạn - Expired
    alerts.add(AlertEntity(
      id: '',
      title: 'Kết thúc cảnh báo mưa lớn',
      content:
          'Cảnh báo mưa lớn đã kết thúc. Tình hình thời tiết đã ổn định. Người dân có thể tiếp tục các hoạt động bình thường.',
      severity: AlertSeverity.medium,
      alertType: AlertType.weather,
      targetAudience: TargetAudience.victims,
      lat: 10.7769,
      lng: 106.7009,
      location: 'TP. Hồ Chí Minh',
      province: 'TP. Hồ Chí Minh',
      district: 'Quận 1',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 3)),
      expiresAt: now.subtract(const Duration(hours: 12)), // Đã hết hạn
    ));

    return alerts;
  }
}





















