// enums.dart
enum TextSizes { small, medium, large }

enum ImageType { asset, network, memory, file }

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

/// App Enums - Tất cả enum trong ứng dụng

/// Loại yêu cầu cứu trợ
enum RequestType {
  food('Thực phẩm', 'Food'),
  water('Nước uống', 'Water'),
  medicine('Thuốc men', 'Medicine'),
  shelter('Nơi trú ẩn', 'Shelter'),
  rescue('Cứu hộ', 'Rescue'),
  clothes('Quần áo', 'Clothes'),
  other('Khác', 'Other');

  final String viName;
  final String enName;
  const RequestType(this.viName, this.enName);

  String toJson() => name;

  static RequestType fromString(String value) {
    return RequestType.values.firstWhere(
          (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RequestType.other,
    );
  }
}

/// Mức độ ưu tiên/khẩn cấp
enum RequestSeverity {
  low('Thấp', 'Low'),
  medium('Trung bình', 'Medium'),
  high('Cao', 'High'),
  urgent('Khẩn cấp', 'Urgent');

  final String viName;
  final String enName;
  const RequestSeverity(this.viName, this.enName);

  String toJson() => name;

  static RequestSeverity fromString(String value) {
    return RequestSeverity.values.firstWhere(
          (severity) => severity.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RequestSeverity.medium,
    );
  }
}

/// Trạng thái yêu cầu
enum RequestStatus {
  pending('Đang chờ', 'Pending'),
  inProgress('Đang xử lý', 'In Progress'),
  completed('Hoàn thành', 'Completed'),
  cancelled('Đã hủy', 'Cancelled');

  final String viName;
  final String enName;
  const RequestStatus(this.viName, this.enName);

  String toJson() => name;

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RequestStatus.pending,
    );
  }
}

/// Loại người dùng
enum UserType {
  victim('Nạn nhân', 'Victim'),
  volunteer('Tình nguyện viên', 'Volunteer'),
  admin('Quản trị viên', 'Admin');

  final String viName;
  final String enName;
  const UserType(this.viName, this.enName);

  String toJson() => name;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
          (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserType.victim,
    );
  }
}

/// Trạng thái tình nguyện viên
enum VolunteerStatus {
  available('Sẵn sàng', 'Available'),
  unavailable('Không sẵn sàng', 'Unavailable'),
  busy('Đang bận', 'Busy');

  final String viName;
  final String enName;
  const VolunteerStatus(this.viName, this.enName);

  String toJson() => name;

  static VolunteerStatus fromString(String value) {
    return VolunteerStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => VolunteerStatus.unavailable,
    );
  }
}

/// Phương thức xác thực
enum AuthMethod {
  email('Email', 'Email'),
  google('Google', 'Google'),
  biometric('Sinh trắc học', 'Biometric'),
  pin('PIN', 'PIN');

  final String viName;
  final String enName;
  const AuthMethod(this.viName, this.enName);

  String toJson() => name;

  static AuthMethod fromString(String value) {
    return AuthMethod.values.firstWhere(
          (method) => method.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AuthMethod.email,
    );
  }
}

/// Trạng thái kết nối mạng
enum NetworkStatus {
  connected('Đã kết nối', 'Connected'),
  disconnected('Mất kết nối', 'Disconnected'),
  syncing('Đang đồng bộ', 'Syncing');

  final String viName;
  final String enName;
  const NetworkStatus(this.viName, this.enName);

  String toJson() => name;

  static NetworkStatus fromString(String value) {
    return NetworkStatus.values.firstWhere(
          (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => NetworkStatus.disconnected,
    );
  }
}

/// Loại thông báo
enum NotificationType {
  sos('SOS Khẩn cấp', 'Emergency SOS'),
  newRequest('Yêu cầu mới', 'New Request'),
  requestAccepted('Yêu cầu được chấp nhận', 'Request Accepted'),
  message('Tin nhắn mới', 'New Message'),
  donation('Quyên góp', 'Donation');

  final String viName;
  final String enName;
  const NotificationType(this.viName, this.enName);

  String toJson() => name;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
          (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => NotificationType.newRequest,
    );
  }
}

