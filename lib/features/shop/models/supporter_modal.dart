import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/util/constants/enums.dart';

/// Lớp đại diện cho một vị trí của người hỗ trợ
/// Chứa tọa độ và thời gian ghi nhận vị trí
class SupporterPosition {
  final double lat; // Vĩ độ
  final double lng; // Kinh độ
  final DateTime timestamp; // Thời điểm ghi nhận vị trí

  SupporterPosition({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  /// Chuyển đổi từ JSON thành đối tượng SupporterPosition
  /// Phương thức tĩnh để tạo đối tượng từ dữ liệu Firestore
  static SupporterPosition fromJson(Map<String, dynamic> json) {
    // Hàm hỗ trợ phân tích DateTime từ nhiều định dạng khác nhau
    DateTime parseDT(dynamic v) {
      if (v is Timestamp) return v.toDate(); // Từ Firestore Timestamp
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now(); // Từ chuỗi
      return DateTime.now(); // Mặc định
    }

    return SupporterPosition(
      lat: (json['Lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['Lng'] as num?)?.toDouble() ?? 0.0,
      timestamp: parseDT(json['Timestamp']),
    );
  }

  /// Chuyển đổi đối tượng thành JSON để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'Lat': lat,
      'Lng': lng,
      'Timestamp': Timestamp.fromDate(timestamp), // Chuyển DateTime thành Firestore Timestamp
    };
  }

  @override
  String toString() => 'SupporterPosition(lat: $lat, lng: $lng, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupporterPosition &&
        other.lat == lat &&
        other.lng == lng &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode ^ timestamp.hashCode;
}

/// Lớp đại diện cho người hỗ trợ (supporter)
/// Lưu trữ thông tin vị trí, khả năng hỗ trợ và lịch sử di chuyển
class SupporterModel {
  final String id; // ID của supporter trong collection supporters
  final String userId; // ID tham chiếu đến user trong collection users
  final String name;
  double lat; // Vĩ độ hiện tại
  double lng; // Kinh độ hiện tại
  int capacity; // Sức chứa/số lượng có thể hỗ trợ cùng lúc
  bool available; // Trạng thái sẵn sàng nhận nhiệm vụ
  String? movementDirection; // Hướng di chuyển (nếu có)
  List<RequestType> supportTypes; // Các loại hình hỗ trợ có thể cung cấp
  List<String> helpedAreas; // Các khu vực đã từng hỗ trợ
  List<SupporterPosition> positions; // Lịch sử các vị trí đã đi qua
  final DateTime createdAt; // Thời điểm tạo bản ghi
  DateTime updatedAt; // Thời điểm cập nhật lần cuối

  // Constructor
  SupporterModel({
    required this.id,
    required this.userId,
    required this.lat,
    required this.lng,
    this.capacity = 1, // Mặc định sức chứa là 1
    this.available = true, // Mặc định sẵn sàng hỗ trợ
    this.movementDirection,
    List<RequestType>? supportTypes,
    List<String>? helpedAreas,
    List<SupporterPosition>? positions,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.name = "",
  })  : supportTypes = supportTypes ?? <RequestType>[], // Khởi tạo danh sách rỗng nếu null
        helpedAreas = helpedAreas ?? <String>[],
        positions = positions ?? <SupporterPosition>[],
        createdAt = createdAt ?? DateTime.now(), // Mặc định là thời gian hiện tại
        updatedAt = updatedAt ?? DateTime.now();

  /// Tạo một đối tượng SupporterModel rỗng (empty)
  /// Sử dụng khi cần khởi tạo giá trị mặc định
  static SupporterModel empty() => SupporterModel(
    id: '',
    userId: '',
    lat: 0.0,
    lng: 0.0,
    capacity: 1,
    available: true,
    movementDirection: null,
    supportTypes: const [],
    helpedAreas: const [],
    positions: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    name: "",
  );

  /// Kiểm tra tính hợp lệ của model
  /// Trả về true nếu có đủ id và userId
  bool get isValid => id.isNotEmpty && userId.isNotEmpty;

  /// Lấy vị trí hiện tại dưới dạng SupporterPosition
  SupporterPosition get currentPosition => SupporterPosition(
    lat: lat,
    lng: lng,
    timestamp: DateTime.now(),
  );

  /// Cập nhật vị trí mới và lưu vào lịch sử
  /// Trả về một bản sao mới với vị trí đã cập nhật
  SupporterModel updatePosition(double newLat, double newLng) {
    final newPositions = List<SupporterPosition>.from(positions)
      ..add(SupporterPosition(
        lat: newLat,
        lng: newLng,
        timestamp: DateTime.now(),
      ));

    return copyWith(
      lat: newLat,
      lng: newLng,
      positions: newPositions,
      updatedAt: DateTime.now(), // Cập nhật thời gian sửa đổi
    );
  }

  /// Kiểm tra người hỗ trợ có hỗ trợ loại yêu cầu cụ thể không
  bool supportsType(RequestType type) => supportTypes.contains(type);

  /// Kiểm tra người hỗ trợ đã từng hỗ trợ ở khu vực cụ thể chưa
  bool hasHelpedInArea(String area) => helpedAreas.contains(area);

  /// Chuyển đổi thành JSON để lưu vào Firestore
  /// [includeId]: Có bao gồm trường ID trong JSON không
  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'UserId': userId,
      'Lat': lat,
      'Lng': lng,
      'Capacity': capacity,
      'Available': available,
      'MovementDirection': movementDirection,
      'SupportTypes': supportTypes.map((e) => e.name).toList(), // Chuyển enum thành string
      'HelpedAreas': helpedAreas,
      'Positions': positions.map((p) => p.toJson()).toList(), // Chuyển danh sách positions thành JSON
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': Timestamp.fromDate(updatedAt),
      'Name': name,
    };

    if (includeId) map['Id'] = id;
    map.removeWhere((k, v) => v == null); // Xóa các trường có giá trị null
    return map;
  }

  /// Factory method: Tạo SupporterModel từ JSON
  factory SupporterModel.fromJson(Map<String, dynamic> json) {
    // Hàm phân tích danh sách RequestType từ JSON
    List<RequestType> parseSupportTypes(dynamic v) {
      if (v == null) return <RequestType>[];
      if (v is List) {
        return v.map<RequestType>((e) {
          try {
            return RequestType.fromString(e.toString()); // Chuyển string thành enum
          } catch (_) {
            return RequestType.other; // Mặc định nếu không tìm thấy
          }
        }).toList();
      }
      return <RequestType>[];
    }

    // Hàm phân tích danh sách vị trí từ JSON
    List<SupporterPosition> parsePositions(dynamic v) {
      if (v == null) return <SupporterPosition>[];
      if (v is List) {
        return v.map<SupporterPosition>((e) {
          if (e is Map<String, dynamic>) {
            return SupporterPosition.fromJson(e);
          } else if (e is Map) {
            return SupporterPosition.fromJson(Map<String, dynamic>.from(e));
          } else {
            return SupporterPosition(lat: 0.0, lng: 0.0, timestamp: DateTime.now());
          }
        }).toList();
      }
      return <SupporterPosition>[];
    }

    // Hàm phân tích DateTime từ nhiều định dạng
    DateTime parseDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return SupporterModel(
      id: (json['Id'] ?? '') as String,
      userId: (json['UserId'] ?? '') as String,
      name: (json['Name'] ?? '') as String,
      lat: (json['Lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['Lng'] as num?)?.toDouble() ?? 0.0,
      capacity: (json['Capacity'] as num?)?.toInt() ?? 1,
      available: (json['Available'] ?? true) as bool,
      movementDirection: json['MovementDirection'] as String?,
      supportTypes: parseSupportTypes(json['SupportTypes']),
      helpedAreas: (json['HelpedAreas'] is List)
          ? List<String>.from(json['HelpedAreas']) // Copy danh sách
          : <String>[],
      positions: parsePositions(json['Positions']),
      createdAt: parseDateTime(json['CreatedAt']),
      updatedAt: parseDateTime(json['UpdatedAt']),
    );
  }

  /// Factory method: Tạo từ Firestore DocumentSnapshot
  /// Sử dụng khi lấy dữ liệu từ document reference
  factory SupporterModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SupporterModel.fromJson({
      ...data,
      'Id': doc.id, // Lấy ID từ document reference
    });
  }

  /// Factory method: Tạo từ Firestore QueryDocumentSnapshot
  /// Sử dụng khi lấy dữ liệu từ query
  factory SupporterModel.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return SupporterModel.fromJson({
      ...data,
      'Id': doc.id, // Lấy ID từ query document
    });
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  /// Phương thức hữu ích cho việc cập nhật không thay đổi trạng thái hiện tại
  SupporterModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? lat,
    double? lng,
    int? capacity,
    bool? available,
    String? movementDirection,
    List<RequestType>? supportTypes,
    List<String>? helpedAreas,
    List<SupporterPosition>? positions,
    DateTime? createdAt,
    DateTime? updatedAt,

  }) {
    return SupporterModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      capacity: capacity ?? this.capacity,
      available: available ?? this.available,
      movementDirection: movementDirection ?? this.movementDirection,
      supportTypes: supportTypes ?? List<RequestType>.from(this.supportTypes), // Tạo bản sao danh sách
      helpedAreas: helpedAreas ?? List<String>.from(this.helpedAreas),
      positions: positions ?? List<SupporterPosition>.from(this.positions),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Luôn cập nhật thời gian sửa đổi
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupporterModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.lat == lat &&
        other.lng == lng &&
        other.capacity == capacity &&
        other.available == available &&
        other.movementDirection == movementDirection &&
        _listEquals(other.supportTypes, supportTypes) &&
        _listEquals(other.helpedAreas, helpedAreas) &&
        _listEquals(other.positions, positions) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      capacity.hashCode ^
      available.hashCode ^
      (movementDirection?.hashCode ?? 0) ^
      supportTypes.hashCode ^
      helpedAreas.hashCode ^
      positions.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return '''SupporterModel(
      id: $id,
      userId: $userId,
      name: $name,
      lat: $lat,
      lng: $lng,
      capacity: $capacity,
      available: $available,
      movementDirection: $movementDirection,
      supportTypes: ${supportTypes.map((e) => e.name).toList()},
      helpedAreas: $helpedAreas,
      positions: ${positions.length} items,
      createdAt: $createdAt,
      updatedAt: $updatedAt
    )''';
  }

  /// Hàm hỗ trợ so sánh 2 danh sách
  /// So sánh từng phần tử trong danh sách
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}